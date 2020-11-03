//
//  Project.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import RealmSwift
import Foundation

typealias ProjectId = String

class Project: Object, ObjectKeyIdentifiable {
    /// The unique ID of the Project.
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    @objc dynamic var _partition: ProjectId = ""
    @objc dynamic var name: String = ""
    /// Declares the _id member as the primary key to the realm.
    override static func primaryKey() -> String? {
        return "_id"
    }
    convenience init(partition: String, name: String) {
        self.init()
        self._partition = partition
        self.name = name
    }
}
