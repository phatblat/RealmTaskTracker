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
//            .alert(isPresented: $showingLogoutAlert) {
//                Alert(title: Text("Log Out"), message: Text(""), primaryButton: .cancel(), secondaryButton: .destructive(Text("Yes, Log Out"), action: {
//                        print("Logging out...")
//                                _ = model.signOut()
//                                    .receive(on: DispatchQueue.main)
//                                    .sink { completion in
//                                        switch completion {
//                                        case .failure(let error):
//                                            print("Error: ", error)
//                                        case .finished:
//                                            print("Logged out")
//                                        }
//                                        presentationMode.wrappedValue.dismiss()
//                                    } receiveValue: { _ in }
//                    }
//                ))
//            }
    }
}
