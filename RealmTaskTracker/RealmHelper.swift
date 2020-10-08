//
//  RealmHelper.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import RealmSwift
import SwiftUI
import Combine
import Foundation

struct Constants {
    static let partitionValue = "My Project"

    static let appVersion: String = {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            else { fatalError("Info.plist does not contain CFBundleShortVersionString") }
        return version
    }()

    static let realmAppId: String = {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "REALM_APP_ID") as? String
            else { fatalError("Info.plist does not contain REALM_APP_ID") }
        return version
    }()
}

extension Realm {
    static func create(_ data: Object) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(data)
        }
    }

    static func destroyAllData() {
        try! FileManager.default.removeItem(at: Self.Configuration.defaultConfiguration.fileURL!)
    }

    static func clearAllData() {
        do {
            let realm = try? Self()
            try realm?.write {
                realm?.deleteAll()
            }
        } catch {
            print("REALM ERROR:", error.localizedDescription)
        }
    }
}

extension Object {
    static func load(from id: String) -> Self? {
        let realm = try? Realm()
        return realm?.object(ofType: Self.self, forPrimaryKey: id)
    }
}

let realmQueueLabel = "co.log-g.RealmTaskTracker.realmQueue"

//public convenience init(label: String, qos: DispatchQoS = .unspecified, attributes: DispatchQueue.Attributes = [], autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency = .inherit, target: DispatchQueue? = nil)
/// Serial background queue
let realmQueue = DispatchQueue(label: realmQueueLabel, qos: .background)
//let realmQueue = DispatchQueue.main

// MARK: - RealmHelpter
/// The helper is just a CRUD simplification for Realm with support for RealmConvertible protocol
class RealmHelper {
    var realm: Realm?

    var partitionValue: String {
//        realm.configuration.syncConfiguration?.partitionValue?.stringValue ?? "No Realm"
        ""
    }

    /// Creates a helper wrapping a new realm
    init() {
//        do {
//            self.realm = try Realm()
//        }
//        catch {
//            fatalError("Error opening local realm: \( error.localizedDescription)")
//        }
    }

    /// Creates a helper wrapping the given realm
    init(realm: Realm) {
        self.realm = realm
    }

    /// Helper to wrap a new realm
    func reinit(realm: Realm) {
        self.realm = realm
    }
}

// MARK: - Static properties & methods
extension RealmHelper {
    static let app = App(id: Constants.realmAppId)

    /// Creates a new realm user with the given credentials.
    /// - Parameters:
    ///   - username: Username used to identify the user.
    ///   - password: Password used to identify the user.
    ///   - completionHandler: Executed on the background realmQueue.
    static func signUp(username: String, password: String, completionHandler: @escaping (_ result: Result<Realm, Error>) -> Void) {

        let emailPassAuth = app.emailPasswordAuth()
        emailPassAuth.registerUser(email: username, password: password) { (error: Error?) in

            guard error == nil else {
                 print("Signup failed: \(error!)")
                 completionHandler(.failure(error!))
                 return
            }

            print("Signup successful!")

            // Registering just registers. Now we need to sign in,
            // but we can reuse the existing username and password.

            signIn(username: username, password: password, completionHandler: completionHandler)
        }
    }

    /// Authenticates a user with the given credentials.
    /// - Parameters:
    ///   - username: Username used to identify the user.
    ///   - password: Password used to identify the user.
    ///   - completionHandler: Executed on the background realmQueue.
    static func signIn(username: String, password: String, completionHandler: @escaping (_ result: Result<Realm, Error>) -> Void) {
        print("Signing in as user: \(username)")

        let credentials = Credentials(email: username, password: password)
        app.login(credentials: credentials) { (user: RealmSwift.User?, error: Error?) in
            guard error == nil else {
                print("Login failed: \(error!)")
                completionHandler(.failure(error!))
                return
            }

            print("Login succeeded")

            guard let user = user else {
                print("No user returned!")
                return
            }

            realmQueue.async {
                // Open a realm.
                do {
                    let config = user.configuration(partitionValue: Constants.partitionValue)
                    let realm = try Realm(configuration: config)
                    completionHandler(.success(realm))
                }
                catch {
                    print("Realm error opening: ", error.localizedDescription)
                    completionHandler(.failure(error))
                }
            }
        }
    }

    /// Signs out the current user.
    /// - Returns: A future with either no value on success, or error on failure.
    static func signOut() -> Future<Void, Error> {
        return Future<Void, Error> { promise in
            guard let user = app.currentUser() else {
                print("Not logged in, no user.")
                promise(.success(()))
                return
            }

            _ = user.logOut()
                .sink { (completion: Subscribers.Completion<Error>) in
                    print("completion")
                    switch completion {
                    case .failure(let error):
                        print("Error logging out: ", error)
                        promise(.failure(error))
                    case .finished:
                        print("Logged out")
                        promise(.success(()))
                    }
                } receiveValue: { _ in }
        }
    }
}

// MARK: - CRUD instance methods
extension RealmHelper {
    func create<O: Object>(_ o: O) {
        guard let realm = realm else { fatalError("Realm has not been initialized yet") }

        do {
            try realm.write {
                realm.add(o)
            }
        }
        catch {
            print("REALM ADD ERROR:", error.localizedDescription)
        }
    }

    func update<O: Object>(o: O) {
        guard let realm = realm else { fatalError("Realm has not been initialized yet") }

        do {
            try realm.write {
                realm.create(O.self, value: o, update: .modified)
            }
        }
        catch {
            print("REALM CREATE ERROR:", error.localizedDescription)
        }
    }

    func updateConvertible<C: RealmConvertible>(_ c: C) {
        guard let realm = realm else { fatalError("Realm has not been initialized yet") }

        do {
            try realm.write {
                realm.create(C.RealmType.self, value: c.realmMap(), update: .modified)
            }
        }
        catch {
            print("REALM CREATE ERROR:", error.localizedDescription)
        }
    }

    func get<O: Object & ObjectIdentifiable>(_ o: O) -> O? {
        guard let realm = realm else { fatalError("Realm has not been initialized yet") }

        return realm.object(ofType: O.self, forPrimaryKey: o.id)
    }

    func delete<O: Object & ObjectIdentifiable>(_ o: O) {
        guard let realm = realm else { fatalError("Realm has not been initialized yet") }

        if let d = get(o) {
            do {
                try realm.write {
                    realm.delete(d)
                }
            }
            catch {
                print("REALM DELETE ERROR:", error.localizedDescription)
            }
        }
    }

    func deleteConvertible<C: RealmConvertible>(_ c: C) {
        guard let realm = realm else { fatalError("Realm has not been initialized yet") }

        guard let o = realm.object(ofType: c.realmType, forPrimaryKey: c.id)
        else { print("Realm object with id \(c.id) not found. Unable to delete"); return }

        delete(o)
    }

    func list<O: Object>(_ o: O.Type) -> RealmSwift.Results<O> {
        guard let realm = realm else { fatalError("Realm has not been initialized yet") }

        return realm.objects(o)
    }
}
