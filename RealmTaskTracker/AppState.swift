//
//  AppState.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import RealmSwift
import Combine
import Foundation

/// Core app logic including Realm app and Combine publishers.
final class AppState: ObservableObject {
    /// Whether or not the UI should be showing a spinner.
    @Published var shouldIndicateActivity = false

    /// List of items in the first group in the realm that will be displayed to the user.
    @Published private(set) var tasks: List<Task>?

    /// Publisher that monitors log in state.
    var loginPublisher = PassthroughSubject<RealmSwift.User, Error>()

    /// Publisher that monitors log out state.
    var logoutPublisher = PassthroughSubject<Void, Error>()

    /// Cancellables to be retained for any Future.
    var cancellables = Set<AnyCancellable>()

    /// Token for a progress notification block.
    var progressNotificationToken: SyncSession.ProgressNotificationToken?

    /// Realm user convenience property.
    var realmUser: RealmSwift.User? {
        app.currentUser
    }

    /// App user.
    private(set) var appUser: User?

    /// Name of the currently logged in user
    private var username: String?

    /// The Realm sync app.
    private let app: RealmSwift.App = {
        let app = RealmSwift.App(id: Constants.realmAppId)
        let syncManager = app.syncManager
        syncManager.logLevel = .info
        syncManager.logger = { (level: SyncLogLevel, message: String) in
            print("[\(level.name)] Sync - \(message)")
        }
        syncManager.errorHandler = { (error, session) in
            print("Sync Error: \(error)")
            // https://docs.realm.io/sync/using-synced-realms/errors
            if let syncError = error as? SyncError {
                switch syncError.code {
                case .permissionDeniedError:
                    // HTTP/1.1 401 Unauthorized
//                    shouldIndicateActivity = false
                    _ = app.currentUser?.logOut()
                        .sink(receiveCompletion: {
                            print($0)
                        }, receiveValue: {
                            print("receive value")
                        })
                case .clientResetError:
                    if let (path, clientResetToken) = syncError.clientResetInfo() {
                        // TODO: close and backup
                        //closeRealmSafely()
                        //saveBackupRealmPath(path)
                        SyncSession.immediatelyHandleError(clientResetToken, syncManager: app.syncManager)
                    }
                default:
                    ()
                }
            }
            if let session = session {
                print("Sync Session: \(session)")
            }
        }
        return app
    }()

    init() {
        // Create a private subject for the opened realm, so that:
        // - if we are not using Realm Sync, we can open the realm immediately.
        // - if we are using Realm Sync, we can open the realm later after login.
        let realmPublisher = PassthroughSubject<Realm, Error>()

        // Specify what to do when the realm opens, regardless of whether
        // we're authenticated and using Realm Sync or not.
        realmPublisher
            .sink(receiveCompletion: { result in
                // Check for failure.
                if case let .failure(error) = result {
                    print("Failed to log in and open realm: \(error.localizedDescription)")
                }
            }, receiveValue: { realm in
                // The realm has successfully opened.
                let syncSession = realm.syncSession!

                // Observe using Combine
                syncSession.publisher(for: \.connectionState)
                    .sink { connectionState in
                        switch connectionState {
                        case .connecting:
                            print("Sync Connecting...")
                        case .connected:
                            print("Sync Connected")
                        case .disconnected:
                            print("Sync Disconnected")
                        default:
                            break
                        }
                    }
                    .store(in: &self.cancellables)

                self.progressNotificationToken = syncSession.addProgressNotification(
                    for: .upload, mode: .forCurrentlyOutstandingWork)
                { (progress) in
                    let transferredBytes = progress.transferredBytes
                    let transferrableBytes = progress.transferrableBytes
                    let transferPercent = progress.fractionTransferred * 100
                    print("Sync Uploaded \(transferredBytes)B / \(transferrableBytes)B (\(transferPercent)%)")
                }

                // If no User has been created for this realm, create one.
                let users = realm.objects(User.self)
                if users.count == 0 {
                    let user = User()
                    do {
                        if let realmUser = self.realmUser {
                            user._id = try ObjectId(string: realmUser.id)
                        }
                        if let name = self.username {
                            user.name = name
                        }
                        try realm.write {
                            realm.add(user)
                        }
                    } catch {
                        print("Error adding user: \(user)")
                    }
                }
                assert(users.count > 0)
                guard let user = users.first else { fatalError("No user!") }

                // Update username
                if let name = self.username {
                    try! realm.write {
                        user.name = name
                    }
                }

                self.appUser = user
                self.tasks = user.tasks
            })
            .store(in: &cancellables)


        // Opens and publishes a synced realm upon user login. Leverages AsyncOpenPublisher.
        loginPublisher
            .receive(on: DispatchQueue.main) // Ensure we update UI elements on the main thread.
            .flatMap { user -> RealmPublishers.AsyncOpenPublisher in
                // Logged in, now open the realm.

                // We want to chain the login to the opening of the realm.
                // flatMap() takes a result and returns a different Publisher.
                // In this case, flatMap() takes the user result from the login
                // and returns the realm asyncOpen's result publisher for further
                // processing.

                // Get a configuration to open the synced realm.
                var configuration = user.configuration(partitionValue: user.id)

                // Only allow User objects in this partition.
                configuration.objectTypes = [User.self, Task.self]
                Realm.Configuration.defaultConfiguration = configuration

                // Loading may take a moment, so indicate activity.
                self.shouldIndicateActivity = true

                // Open the realm and return its publisher to continue the chain.
                return Realm.asyncOpen(configuration: configuration)
            }
            .receive(on: DispatchQueue.main) // Ensure we update UI elements on the main thread.
            .map { // For each realm result, whether successful or not, always stop indicating activity.
                self.shouldIndicateActivity = false // Stop indicating activity.
                return $0 // Forward the result as-is to the next stage.
            }
            .subscribe(realmPublisher) // Forward the opened realm to the handler we set up earlier.
            .store(in: &cancellables)

        // Monitor logout state and unset the items list on logout.
        logoutPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: {
                self.username = nil
                self.tasks = nil
                self.progressNotificationToken?.invalidate()
            })
            .store(in: &cancellables)

        // If we already have a current user from a previous app
        // session, announce it to the world.
        if let user = app.currentUser {
            loginPublisher.send(user)
        }
    }
}

extension AppState {
    func signUp(username: String, password: String, completionHandler: @escaping (_ result: Result<Void, Error>) -> Void) {
        DispatchQueue.main.async {
            self.shouldIndicateActivity = true
        }

        app.emailPasswordAuth.registerUser(email: username, password: password) { (error: Error?) in
            if let error = error {
                DispatchQueue.main.async {
                    self.shouldIndicateActivity = false
                }
                print("Signup failed: \(error)")
                completionHandler(.failure(error))
                return
            }

            print("Signup successful")

            // Registering just creates a new user. Now we need to sign in,
            // but we can reuse the existing username and password.

            self.signIn(username: username, password: password, completionHandler: completionHandler)
        }
    }

    func signIn(username: String, password: String, completionHandler: @escaping (_ result: Result<Void, Error>) -> Void) {
        DispatchQueue.main.async {
            self.shouldIndicateActivity = true
        }

        let credentials = Credentials.emailPassword(email: username, password: password)
        app.login(credentials: credentials)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                self.shouldIndicateActivity = false

                switch $0 {
                case .finished:
                    completionHandler(.success(()))
                    break
                case .failure(let error):
                    print("Login failed: \(error)")
                    completionHandler(.failure(error))
                }
            }, receiveValue: { user in
                print("Login succeeded")
                self.username = username
                self.loginPublisher.send(user)
            })
            .store(in: &cancellables)
    }

    func signOut() {
        shouldIndicateActivity = true

        app.currentUser?.logOut()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: {
                self.shouldIndicateActivity = false
                self.logoutPublisher.send($0)
            })
            .store(in: &cancellables)
    }
}
