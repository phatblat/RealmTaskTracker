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
let partitionValue = "partition-value"
let app = RealmSwift.App(id: appId)

// MARK: Main View
/// The main screen that determines whether to present the LoginView or the TasksView for the one group in the realm.
struct AsyncOpenView: View {

    @State var user: User?
    @AsyncOpen(appId: appId, partitionValue: "60ac4fab713d3980e99a61d0", timeout: 5000) var asyncOpen

    var body: some View {
        VStack {
            switch asyncOpen {
            case .connecting:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            case .waitingForUser:
                ProgressView("Waiting for user to be logged in...")
            case .open(let realm):
                ListView()
                    .environment(\.realm, realm)
            case .error(let error):
                ErrorView(error: error)
            case .progress(let progress):
                ProgressView(progress)
            }
        }
    }
}
