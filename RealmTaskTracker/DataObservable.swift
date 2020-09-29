//
//  DataObservable.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import RealmSwift
import SwiftUI

class DataObservable<Type: RealmConvertible>: ObservableObject {
    private let helper = RealmHelper()
    private var notificationTokens: [NotificationToken] = []
    private var realmItems: RealmSwift.Results<Type.RealmType>

    @Published private(set) var items: [Type]

    init(_ filter: String = "") {
        // filter can be used to scope data on init

        if filter.count > 0 {
            realmItems = helper.list(Type.RealmType.self).filter(filter)
        } else {
            realmItems = helper.list(Type.RealmType.self)
        }

        items = realmItems.map { Type($0) }
        watchRealm()
    }

    func store(realm: Realm) {
        helper.realm = realm
        notificationTokens = []
    }

    private func watchRealm() {
        notificationTokens.append(realmItems.observe { _ in
            self.updateItems()
        })
    }

    private func updateItems() {
        DispatchQueue.main.async {
            self.items = self.realmItems.map { Type($0) }
        }
    }

    deinit { notificationTokens = [] }

    func create(_ item: Type) {
        helper.create(item.realmMap())
    }

    func update(_ updatingItems: [Type]) {
        for item in updatingItems {
            if items.contains(item) {
                // this items exists in db so we can update it
                helper.update(o: item.realmMap())
            }
        }
    }

    func delete(_ item: Type) {
        let realm = item.realmMap()
        helper.delete(realm)
    }

    func deleteAll() {
        for item in items { delete(item) }
    }

    func get(id: ObjectIdentifier) -> Type? {
        items.first{ $0.id == id }
    }

    func replaceItems(with newItems: [Type]) {
        for item in items {
            // if current item is not in newItems, delete it
            if newItems.first(where: { $0.id == item.id }) == nil {
                delete(item)
            }
        }

        for item in newItems {
            // adds or creates item
            helper.updateConvertible(item)
        }

        objectWillChange.send()
    }


    // Dynamic Realm Binding for live data editing

    func binding(_ item: Type) -> Binding<Type> {
        Binding<Type>(get: {
            return self.items.first(where: { $0.id == item.id }) ?? item
        }, set: helper.updateConvertible)
    }
}
