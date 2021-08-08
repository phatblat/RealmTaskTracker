//
//  Project.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import RealmSwift
import Foundation

class Project: Object, ObjectKeyIdentifiable {
    /// The unique ID of the Project.
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
