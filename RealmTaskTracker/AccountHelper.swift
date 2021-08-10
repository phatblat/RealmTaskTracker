//
//  AccountHelper.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 8/9/21.
//

import Combine
import RealmSwift
import Foundation

/// Email and password authentication helper.
class AccountHelper {
    /// Whether or not the UI should be showing a spinner.
    @Published var shouldIndicateActivity = false

    /// Container for publishers.
    var cancellables = Set<AnyCancellable>()

    /// Creates a new account.
    /// - Parameters:
    ///   - username: Login username (normally this should be an email).
    ///   - password: Super-secret password.
    ///   - completionHandler: Delivers a results with either a realm user or an error.
    func signUp(username: String, password: String, completionHandler: @escaping (_ result: Result<RealmSwift.User, Error>) -> Void) {
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

    /// Logs in with an existing account.
    /// - Parameters:
    ///   - username: Login username (normally this should be an email).
    ///   - password: Super-secret password.
    ///   - completionHandler: Delivers a results with either a realm user or an error.
    func signIn(username: String, password: String, completionHandler: @escaping (_ result: Result<RealmSwift.User, Error>) -> Void) {
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
                    break
                case .failure(let error):
                    print("Login failed: \(error)")
                    completionHandler(.failure(error))
                }
            }, receiveValue: { user in
                print("Login succeeded")
                completionHandler(.success(user))
            })
            .store(in: &cancellables)
    }

    /// Signs out the current user.
    func signOut() {
        shouldIndicateActivity = true

        app.currentUser?.logOut()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: {
                self.shouldIndicateActivity = false
                print("Logout complete")
            })
            .store(in: &cancellables)
    }
}
