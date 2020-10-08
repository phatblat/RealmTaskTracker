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
}

extension DataStore {
    func signUp(username: String, password: String, completionHandler: @escaping (_ result: Result<Void, Error>) -> Void) {
        RealmHelper.signUp(username: username, password: password) { result in
            switch result {
            case .failure(let error):
                print("Signup failed: \(error)")
                completionHandler(.failure(error))
            case .success(let config):
                print("Signup successful!")
                self.taskDB.update(config: config)
                completionHandler(.success(()))
            }
        }
    }

    func signIn(username: String, password: String, completionHandler: @escaping (_ result: Result<Void, Error>) -> Void) {
        RealmHelper.signIn(username: username, password: password) { result in
            switch result {
            case .failure(let error):
                print("Login failed: \(error)")
                completionHandler(.failure(error))
            case .success(let config):
                print("Login succeeded!")
                self.taskDB.update(config: config)
                completionHandler(.success(()))
            }
        }
    }
}
