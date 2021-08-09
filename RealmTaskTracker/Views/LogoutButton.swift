//
//  LogoutButton.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 11/2/20.
//

import SwiftUI

/// A button that handles logout requests.
struct LogoutButton: View {
    @EnvironmentObject var state: AppState
    @State var showingLogoutAlert = false

    var body: some View {
        Button("Log Out") {
            showingLogoutAlert = true
        }
        .disabled(state.shouldIndicateActivity)
        .alert(isPresented: $showingLogoutAlert) {
            Alert(title: Text("Log Out"),
                  primaryButton: .cancel(),
                  secondaryButton: .destructive(
                    Text("Yes"), action: {
                        print("Logging out...")
                        state.signOut()
                    }
                  )
            )
        }
    }
}
