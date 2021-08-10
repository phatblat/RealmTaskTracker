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
            let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "previewRealm", objectTypes: [Task.self]))
            try! realm.write {
                _ = Task(name: "New task")
                _ = Task(name: "Another task")
            }
            return realm
        }
    }
}
