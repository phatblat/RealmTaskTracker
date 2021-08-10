//
//  AsyncOpenView.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 8/9/21.
//

import RealmSwift
import SwiftUI

// You can find your Realm app ID in the Realm UI.
let appId = Constants.realmAppId

// The partition determines which subset of data to access, this is configured in the Realm UI too.
let partitionValue = Constants.testuserId
let app = RealmSwift.App(id: appId)

// MARK: Main View
/// View that presents the ListView once a user is logged in.
struct AsyncOpenView: View {

//    @ObservedObject var user: User
//    @Environment(\.partitionValue) var partitionValue

    @AsyncOpen(appId: appId, partitionValue: partitionValue, timeout: 5000) var asyncOpen

    var body: some View {
        VStack {
            switch asyncOpen {
            case .connecting:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            case .waitingForUser:
                ProgressView("Waiting for user to be logged in...")
            case .open(let realm):
                ListView(editTask: Task())
                    .environment(\.realm, realm)
            case .error(let error):
                ErrorView(error: error)
            case .progress(_):
                ProgressView()
            }
        }
    }
}
