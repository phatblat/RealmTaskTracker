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

    var body: some View {
        Button("Log Out", action: state.signOut)
            .disabled(state.shouldIndicateActivity)
    }
}
