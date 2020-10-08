//
//  RealmTask.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import RealmSwift
import Foundation

protocol ObjectIdentifiable: Identifiable {
    var id: ObjectIdentifier { get }
    var _id: ObjectId { get }
}

protocol RealmInitializable {
    associatedtype RealmType: Object & ObjectIdentifiable
    init(_ dest: RealmType)
}

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
struct Task: Statusable {
    var _id: ObjectId
    var name: String
    var status: String
    var assignee: User?
}

extension Task: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._id == rhs._id
    }
}

extension Task: RealmConvertible {
    var realmType: RealmTask.Type { RealmType.self }

    init(_ obj: RealmTask) {
        self._id = obj._id
        self.name = obj.name
        self.status = obj.status
        self.assignee = obj.assignee
    }

    init(_id: ObjectId = ObjectId.generate(), name: String, status: TaskStatus = .Open, assignee: User? = nil) {
        self._id = _id
        self.name = name
        self.status = status.rawValue
        self.assignee = assignee
    }

    var realmObject: RealmTask {
        RealmTask(self)
    }
}

extension Task: Identifiable, ObjectIdentifiable {
    var id: ObjectIdentifier {
        ObjectIdentifier(_id)
    }
}

// MARK: - RealmTask
class RealmTask: Object, ObjectIdentifiable, Statusable {
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    @objc dynamic var _partition: ProjectId = ""
    @objc dynamic var name: String = ""
    @objc dynamic var status = TaskStatus.Open.rawValue
    @objc dynamic var assignee: User?

    override static func primaryKey() -> String? {
        return "_id"
    }
    convenience init(partition: String, name: String) {
        self.init()
        self._partition = partition
        self.name = name
    }
}

extension RealmTask {
    convenience init(_ obj: Task) {
        self.init()
        self._id = obj._id
        self.name = obj.name
        self.status = obj.status
        self.assignee = obj.assignee
    }
}

extension RealmTask: Identifiable {
    var id: ObjectIdentifier {
        ObjectIdentifier(_id)
    }
}
