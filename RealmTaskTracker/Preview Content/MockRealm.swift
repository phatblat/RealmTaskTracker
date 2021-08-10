//
//  MockRealms.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 8/9/21.
//

import RealmSwift

class MockRealms {
    static var previewRealm: Realm {
        get {
            let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "previewRealm", objectTypes: [User.self, Task.self]))
            try! realm.write {
                let user = User()
                user.name = "phatblat"
                user.tasks.append(Task(name: "New task"))
                user.tasks.append(Task(name: "Another task"))
            }
            return realm
        }
    }
}
