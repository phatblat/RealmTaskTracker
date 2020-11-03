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
    @Published private(set) var tasks: Results<Task>

    private let app = App(id: Constants.realmAppId)
    private var token: NotificationToken?

    init() {
        app.syncManager.logLevel = .debug
        app.syncManager.errorHandler = { (error, session) in
            print("Sync Error: \(error)")
            if let session = session {
                print("Session: \(session)")
            }
        }

        if let user = app.currentUser {
            defaultConfig(user)

            // Hopefully non-empty synced realm
            let realm = try! Realm()
            tasks = realm.objects(Task.self).sorted(byKeyPath: "_id")
            token = realm.observe { (notification: Realm.Notification, realm: Realm) in
                self.tasks = realm.objects(Task.self).sorted(byKeyPath: "_id")
            }
            return
        }

        // Initially empty from an empty local realm
        tasks = try! Realm().objects(Task.self).sorted(byKeyPath: "_id")

        app.login(credentials: Credentials.anonymous) { result in
            switch result {
            case .failure(let error):
                print("Login failed: \(error)")

            case .success(let user):
                print("Successful login: \(user)")

                defaultConfig(user)

                DispatchQueue.main.async {
                     self.loadTasks { result in
                        switch result {
                        case .failure(let error):
                            print("Error opening realm: \(error)")
                        case .success(let results):
                            self.tasks = results
                        }
                    }
                }
            }
        }
    }


    private func loadTasks(completion: @escaping (_ result: Result<Results<Task>, Error>) -> Void) {
        _ = Realm.asyncOpen() { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let realm):
                self.token = realm.observe { (notification: Realm.Notification, realm: Realm) in
                    self.tasks = realm.objects(Task.self).sorted(byKeyPath: "_id")
                }

                let results = realm.objects(Task.self).sorted(byKeyPath: "_id")
                completion(.success(results))
            }
        }
    }
}

extension AppState {
    func signUp(username: String, password: String, completionHandler: @escaping (_ result: Result<Void, Error>) -> Void) {
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

        let credentials = Credentials.emailPassword(email: username, password: password)
        app.login(credentials: credentials) { result in
            switch result {
            case .failure(let error):
                print("Login failed: \(error)")
                completionHandler(.failure(error))
            case .success(let user):
                print("Login succeeded")

                defaultConfig(user)
                completionHandler(.success(()))
            }
        }
    }
}
