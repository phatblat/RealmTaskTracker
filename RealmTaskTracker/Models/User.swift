//
//  User.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/16/20.
//

import RealmSwift

class User: Object, ObjectKeyIdentifiable {
    /// Unique ID of the User.
    @Persisted(primaryKey: true) var _id: ObjectId

    /// The username.
    @Persisted var name: String

    /// Collection of Tasks belonging to the User.
    @Persisted var tasks: List<Task>
}
