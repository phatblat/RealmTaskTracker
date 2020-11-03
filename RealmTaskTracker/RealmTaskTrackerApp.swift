//
//  RealmTaskTrackerApp.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/15/20.
//

import SwiftUI

@main
struct RealmTaskTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(AppState())
        }
    }
}
