//
//  MainView.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 11/9/20.
//

import SwiftUI

// MARK: Main View
/// The main screen that determines whether to present the LoginView or the TasksView for the one group in the realm.
struct MainView: View {
    /// The state of this application.
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationView {
            ZStack {
                // If a realm is open for a logged in user, show the TasksView, otherwise show the LoginView
                if let _ = state.tasks {
                    TasksView()
                        .navigationBarTitle("Tasks")
                        .disabled(state.shouldIndicateActivity)
                } else {
                    LoginView()
                        .navigationBarTitle("Login")
                }

                // If the app is doing work in the background,
                // overlay an ActivityIndicator
                if state.shouldIndicateActivity {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
        }
    }
}
