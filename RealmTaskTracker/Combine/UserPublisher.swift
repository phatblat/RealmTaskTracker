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
    @Published private(set) var user: User? {
        didSet {
            paritionValue = user?.id
        }
    }

    /// Partition value aka the user identifier.
    @Published private(set) var paritionValue: String?

    /// Container for publishers.
    private var cancellables = Set<AnyCancellable>()

    /// Immediately publishes user if one is already logged in.
    init() {
        if let user = app.currentUser {
            self.user = user
        }
    }

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

extension UserPublisher: Publisher {
    typealias Output = User
    typealias Failure = Never

    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, User == S.Input {
        let subscription = Subscription(userPublisher: self, target: subscriber)
        subscriber.receive(subscription: subscription)
    }

    class Subscription<Target: Subscriber>: Combine.Subscription
        where Target.Input == Output {

        private let userPublisher: UserPublisher
        private var target: Target?

        init(userPublisher: UserPublisher, target: Target) {
            self.userPublisher = userPublisher
            self.target = target
        }

        func request(_ demand: Subscribers.Demand) {
            var demand = demand

            if let target = target, demand > 0 {
                if let value = userPublisher.user {
                    demand -= 1
//                    demand += target.receive(value)
                    _ = target.receive(value)
                }
            }
        }

        func cancel() {
            target?.receive(completion: .finished)
            target = nil
        }
    }
}

extension UserPublisher: Equatable {
    static func == (lhs: UserPublisher, rhs: UserPublisher) -> Bool {
        lhs.user == rhs.user
    }
}
