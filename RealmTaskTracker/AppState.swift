//
//  AppState.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import RealmSwift
import Combine
import Foundation

let defaultConfig = { (user: RealmSwift.User) in
    // Show only the active acronyms
    Realm.Configuration.defaultConfiguration = user.configuration(partitionValue: Constants.partitionValue)
}

final class AppState: ObservableObject {
    /// Publisher that monitors log in state.
    var loginPublisher = PassthroughSubject<User, Error>()

    /// Publisher that monitors log out state.
    var logoutPublisher = PassthroughSubject<Void, Error>()

    /// Cancellables to be retained for any Future.
    var cancellables = Set<AnyCancellable>()

    /// Whether or not the app is active in the background.
    @Published var shouldIndicateActivity = false

    /// The list of items in the first group in the realm that will be displayed to the user.
    @Published private(set) var tasks: Results<Task>?

    /// The Realm sync app.
    private let app: RealmSwift.App = {
        let app = App(id: Constants.realmAppId)
        app.syncManager.logLevel = .debug
        app.syncManager.errorHandler = { (error, session) in
            print("Sync Error: \(error)")
            // https://docs.realm.io/sync/using-synced-realms/errors
            if let syncError = error as? SyncError {
                switch syncError.code {
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
                print("Session: \(session)")
            }
        }
        return app
    }()

    private var token: NotificationToken?

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
                // If no group has been created for this app, create one.
                if realm.objects(Task.self).count == 0 {
                    try! realm.write {
                        realm.add(Task())
                    }
                }
                assert(realm.objects(Task.self).count > 0)
                self.tasks = realm.objects(Task.self)
            })
            .store(in: &cancellables)


        // Monitor login state and open a realm on login.
        loginPublisher
            .receive(on: DispatchQueue.main) // Ensure we update UI elements on the main thread.
            .flatMap { user -> RealmPublishers.AsyncOpenPublisher in
                // Logged in, now open the realm.

                // We want to chain the login to the opening of the realm.
                // flatMap() takes a result and returns a different Publisher.
                // In this case, flatMap() takes the user result from the login
                // and returns the realm asyncOpen's result publisher for further
                // processing.

                // We use "SharedPartition" as the partition value so that all users of this app
                // can see the same data. If we used the user.id, we could store data per user.
                // However, with anonymous authentication, that user.id changes upon logout and login,
                // so we will not see the same data or be able to sync across devices.
                let configuration = user.configuration(partitionValue: "SharedPartition")

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
            .store(in: &self.cancellables)

        // Monitor logout state and unset the items list on logout.
        logoutPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: {
                self.tasks = nil
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
        shouldIndicateActivity = true

        let emailPassAuth = app.emailPasswordAuth
        emailPassAuth.registerUser(email: username, password: password) { (error: Error?) in
            guard error == nil else {
                 print("Signup failed: \(error!)")
                 completionHandler(.failure(error!))
                 return
            }

            print("Signup successful!")

            // Registering just registers. Now we need to sign in,
            // but we can reuse the existing username and password.

            self.signIn(username: username, password: password, completionHandler: completionHandler)
        }
    }

    func signIn(username: String, password: String, completionHandler: @escaping (_ result: Result<Void, Error>) -> Void) {
        shouldIndicateActivity = true

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
            }, receiveValue: {
                print("Login succeeded")
                self.loginPublisher.send($0)
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
