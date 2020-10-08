//
//  User.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/16/20.
//

import RealmSwift
import Foundation

class User: Object {
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    @objc dynamic var _partition: ProjectId = ""
    @objc dynamic var image: String? = nil
    @objc dynamic var name: String = ""
    @objc dynamic var user_id: String = ""
    override static func primaryKey() -> String? {
        return "_id"
    }
}
