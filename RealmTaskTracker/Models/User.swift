//
//  User.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/16/20.
//

import RealmSwift
import Foundation

class User: Object, ObjectKeyIdentifiable {
    /// Declares the _id member as the primary key to the realm.
    override static func primaryKey() -> String? {
        return "_id"
    }

    /// The unique ID of the User.
    @objc dynamic var _id: ObjectId = ObjectId.generate()

    /// The username.
    @objc dynamic var name: String = ""

    /// The collection of Tasks in this group.
    let tasks = List<Task>()
}
