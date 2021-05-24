//
//  AuthDelegate.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 5/24/21.
//

import RealmSwift

class AuthDelegate: ASLoginDelegate {
    func authenticationDidComplete(error: Error) {
        print(error)
    }

    func authenticationDidComplete(user: RealmSwift.User) {
        print("User logged in: \(user) (\(user.id)")
    }
}
