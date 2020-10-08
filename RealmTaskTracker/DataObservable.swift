//
//  DataObservable.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import RealmSwift
import SwiftUI

class DataObservable<Type: RealmConvertible>: ObservableObject {
    // filter can be used to scope data on init
    private let filter: String

    /// Starts out as a local realm
//    private var helper = RealmHelper()
    private var notificationTokens: [NotificationToken] = []
    private var realmItems: RealmSwift.Results<Type.RealmType>?

    @Published private(set) var items: [Type] = []

    init(_ filter: String = "") {
        self.filter = filter

        //updateItems()

//        if filter.count > 0 {
//            realmItems = helper.list(Type.RealmType.self).filter(filter)
//        } else {
//            realmItems = helper.list(Type.RealmType.self)
//        }
//
//        self.items = self.realmItems.map { Type($0) }
//
//        watchRealm()
    }


    deinit { notificationTokens = [] }

    func update(config: Realm.Configuration) {
        Realm.Configuration.defaultConfiguration = config
//        helper = RealmHelper()
        notificationTokens = []

        updateItems()
        watchRealm()
    }

    private func watchRealm() {
        guard let realmItems = realmItems else {
            print("No realmItems yet")
            return
        }

        // https://academy.realm.io/posts/realm-notifications-on-background-threads-with-swift/
        self.notificationTokens.append(realmItems.observe(on: DispatchQueue.main) { _ in
            self.updateItems()
        })
    }

    private func updateItems() {
        let helper = RealmHelper()
        var realmItems: RealmSwift.Results<Type.RealmType>
        if self.filter.count > 0 {
            realmItems = helper.list(Type.RealmType.self).filter(self.filter)
        } else {
            realmItems = helper.list(Type.RealmType.self)
        }
        self.realmItems = realmItems

        let items: [Type] = realmItems.map { Type($0) }

        // Published properties need to be updated on the main queue
        DispatchQueue.main.async {
            self.items = items
        }
    }

    func create(_ item: Type) {
        let helper = RealmHelper()
        helper.create(item.realmObject)
    }

    func update(_ item: Type) {
        update([item])
    }
    
    func update(_ updatingItems: [Type]) {
        let helper = RealmHelper()
        for item in updatingItems {
            if items.contains(item) {
                // this items exists in db so we can update it
                helper.update(o: item.realmObject)
            }
        }
        updateItems()
    }

    func delete(_ item: Type) {
        let helper = RealmHelper()
        let realm = item.realmObject
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
            let helper = RealmHelper()
            // adds or creates item
            helper.updateConvertible(item)
        }

        objectWillChange.send()
    }

    /// Dynamic Realm Binding for live data editing
    func binding(_ item: Type) -> Binding<Type> {
        Binding<Type>(get: {
            return self.items.first(where: { $0.id == item.id }) ?? item
        }, set: RealmHelper().updateConvertible)
    }
}
