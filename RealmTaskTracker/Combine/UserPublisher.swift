//
//  UserPublisher.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 8/9/21.
//

import Combine
import RealmSwift
import Foundation

/// Email and password authentication helper.
class UserPublisher: ObservableObject {
    /// Whether or not the UI should be showing a spinner.
    @Published private(set) var shouldIndicateActivity = false

    /// User model, populated once logged in.
    @Published private(set) var user: User?

    /// Partition value aka the user identifier.
    @Published private(set) var paritionValue: String?

    /// Container for publishers.
    private var cancellables = Set<AnyCancellable>()

    /// Creates a new account.
    /// - Parameters:
    ///   - username: Login username (normally this should be an email).
    ///   - password: Super-secret password.
    ///   - completion: Result containing a user or error
    func signUp(username: String, password: String, completion: @escaping (_ result: Result<User, Error>) -> Void) {
        DispatchQueue.main.async {
            self.shouldIndicateActivity = true
        }

        app.emailPasswordAuth.registerUser(email: username, password: password) { (error: Error?) in
            if let error = error {
                DispatchQueue.main.async {
                    self.shouldIndicateActivity = false
                }
                debugPrint("Signup failed: \(error)")
                return
            }

            debugPrint("Signup successful")

            // Sign in with the new user
            self.signIn(username: username, password: password, completion: completion)
        }
    }

    /// Logs in with an existing account.
    /// - Parameters:
    ///   - username: Login username (normally this should be an email).
    ///   - password: Super-secret password.
    ///   - completion: Result containing a user or error
    func signIn(username: String, password: String, completion: @escaping (_ result: Result<User, Error>) -> Void) {
        DispatchQueue.main.async {
            self.shouldIndicateActivity = true
        }

        let credentials = Credentials.emailPassword(email: username, password: password)
        app.login(credentials: credentials)
            .receive(on: DispatchQueue.main)
            .sink ( receiveCompletion: {
                switch $0 {
                case .failure(let error):
                    debugPrint("Sign-in failed")
                    completion(.failure(error))
                case .finished: ()
            }}, receiveValue: { user in
                debugPrint("Sign-in succeeded")
                self.user = user
                self.paritionValue = user.id
                completion(.success(user))
            })
            .store(in: &cancellables)
    }

    /// Signs out the current user.
    func signOut() {
        DispatchQueue.main.async {
            self.shouldIndicateActivity = true
        }

        app.currentUser?.logOut()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: {
                self.shouldIndicateActivity = false
                self.user = nil
                debugPrint("Logout complete")
            })
            .store(in: &cancellables)
    }
}
