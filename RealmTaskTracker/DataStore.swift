//
//  DataStore.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/26/20.
//

import Combine
import Foundation

final class DataStore: ObservableObject {

    private var todoCancellable: AnyCancellable?
    private(set) var todoDB = DataObservable<Task>()

    // could store related references to other related DataObservables

    @Published private(set) var todos: [Task] = []

    init() {
        todoDB = DataObservable<Task>()
        todoCancellable = todoDB.$items.assign(to: \.todos, on: self)
    }
}
