//
//  RealmTask.swift
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
class Task: Object, Statusable {
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    @objc dynamic var _partition: ProjectId = Constants.partitionValue
    @objc dynamic var name: String = ""
    @objc dynamic var status = TaskStatus.Open.rawValue
    @objc dynamic var assignee: User?

    override static func primaryKey() -> String? {
        return "_id"
    }
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

// MARK: - Identifiable
extension Task: Identifiable {
    var id: ObjectIdentifier {
        ObjectIdentifier(_id)
    }
}
