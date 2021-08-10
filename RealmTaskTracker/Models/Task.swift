//
//  Task.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import RealmSwift

// MARK: - TaskStatus
enum TaskStatus: String, PersistableEnum {
    case Open
    case InProgress
    case Complete
}

// MARK: - Task
class Task: Object, ObjectKeyIdentifiable {
    /// Declares the _id member as the primary key to the realm.
    /// Unique ID of the Task.
    @Persisted(primaryKey: true) var _id: ObjectId

    /// Displayed name of the task.
    @Persisted var name: String

    /// Current status of the task. Defaults to "Open".
    @Persisted var status: TaskStatus

    /// Initializer for previews.
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
