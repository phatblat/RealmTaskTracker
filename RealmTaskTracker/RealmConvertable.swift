//
//  RealmConvertable.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import RealmSwift
import SwiftUI
import Foundation

/// Specifies a type which can be converted to a realm object.
protocol RealmConvertible where Self: Equatable & ObjectIdentifiable & RealmInitializable {
    var realmType: RealmType.Type { get }
    init(_ dest: RealmType)
    var realmObject: RealmType { get }
}

extension RealmConvertible {
    var realmType: RealmType.Type { RealmType.self }
}

// Dynamic Realm Binding for live data editing

extension RealmConvertible {
    func realmBinding() -> Binding<Self> {
        let helper = RealmHelper()
        return Binding<Self>(get: {
            if let realmObject = helper.get(self.realmObject) {
                // get the latest realm version for most up to date data and map back to abstracted structs on init
                return Self(realmObject)
            } else {
                // otherwise return self as it's the most up to date version of the data struct
                return self
            }
        }, set: helper.updateConvertible)
    }
}
