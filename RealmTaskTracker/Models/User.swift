//
//  User.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/16/20.
//

import RealmSwift

class User: Object, ObjectKeyIdentifiable {
    /// The unique ID of the User.
    @Persisted(primaryKey: true) var _id: ObjectId

    /// The username.
    @Persisted var name: String = ""

    /// The collection of Tasks in this group.
    @Persisted var tasks = List<Task>()
}
