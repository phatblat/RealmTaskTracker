//
//  DataStore.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import RealmSwift
import Combine
import Foundation

final class DataStore: ObservableObject {
    private(set) var taskDB = DataObservable<Task>()
    private var taskCancellable: AnyCancellable?

    @Published private(set) var tasks: [Task] = []

    init() {
        taskDB = DataObservable<Task>()
        taskCancellable = taskDB.$items.assign(to: \.tasks, on: self)
    }

    func store(realm: Realm) {
        taskDB.store(realm: realm)
    }
}
