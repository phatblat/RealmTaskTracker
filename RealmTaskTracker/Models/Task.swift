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
    /// The unique ID of the Task.
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    @objc dynamic var _partition: ProjectId = Constants.partitionValue

    /// The displayed name of the task.
    @objc dynamic var name: String = ""

    /// The task's current status. Defaults to "Open".
    @objc dynamic var status = TaskStatus.Open.rawValue
    @objc dynamic var assignee: User?

    /// Declares the _id member as the primary key to the realm.
    override static func primaryKey() -> String? {
        return "_id"
    }
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
