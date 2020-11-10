//
//  Task.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import RealmSwift
import Foundation

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
    override static func primaryKey() -> String? {
        return "_id"
    }

    /// Unique ID of the Task.
    @objc dynamic var _id: ObjectId = ObjectId.generate()

    /// Displayed name of the task.
    @objc dynamic var name: String = ""

    /// Current status of the task. Defaults to "Open".
    @objc dynamic var status = TaskStatus.Open.rawValue

    /// Backlink to the `User` that created this task.
    let user = LinkingObjects(fromType: User.self, property: "tasks")

    /// Initializer for previews.
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
