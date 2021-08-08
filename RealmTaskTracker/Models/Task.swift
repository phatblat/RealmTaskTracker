//
//  Task.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import RealmSwift

// MARK: - TaskStatus
enum TaskStatus: String {
case Open
case InProgress
case Complete
}

// MARK: - Statusable
protocol Statusable {
    var status: String { get set }
}

extension Statusable {
    /// Converts the status string to an enum.
    var statusEnum: TaskStatus {
        get {
            return TaskStatus(rawValue: status) ?? .Open
        }
        set {
            status = newValue.rawValue
        }
    }
}

// MARK: - Task
class Task: Object, ObjectKeyIdentifiable, Statusable {
    /// Declares the _id member as the primary key to the realm.
    /// Unique ID of the Task.
    @Persisted(primaryKey: true) var _id: ObjectId

    /// Displayed name of the task.
    @Persisted var name: String = ""

    /// Current status of the task. Defaults to "Open".
    @Persisted var status = TaskStatus.Open.rawValue

    /// Backlink to the `User` that created this task.
    let user = LinkingObjects(fromType: User.self, property: "tasks")

    /// Initializer for previews.
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
