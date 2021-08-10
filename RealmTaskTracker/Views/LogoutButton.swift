//
//  LogoutButton.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 11/2/20.
//

import SwiftUI

/// A button that handles logout requests.
struct LogoutButton: View {

    @State var showingLogoutAlert = false

    let account = UserPublisher()
    let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }
    var body: some View {
        Button("Log Out") {
            showingLogoutAlert = true
        }
        .alert(isPresented: $showingLogoutAlert) {
            Alert(title: Text("Log Out"),
                  primaryButton: .cancel(),
                  secondaryButton: .destructive(
                    Text("Yes"), action: {
                        print("Logging out...")
                        account.signOut()
                        action()
                    }
                  )
            )
        }
    }
}
