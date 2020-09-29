//
//  WelcomeView.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/15/20.
//

import Realm
import RealmSwift
import Combine
import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var data: DataStore

    @State private var loading = false
    @State private var signedIn = false
    @State private var username = "Testuser"
    @State private var password = "password"
    @State private var message = "Version: \(Constants.appVersion)"

    var body: some View {
        NavigationView {
            LoadingView(isShowing: $loading) {
                VStack {
                    Text("Please enter a username and password.")
                        .padding()
                    Form {
                        TextField("Username", text: $username)
                        SecureField("Password", text: $password)
                        Button("Sign In", action: signIn)
                        Button("Sign Up", action: signUp)
                    }
                    NavigationLink(destination: TasksView(), isActive: $signedIn) { EmptyView () }
                    Text(message)
                }
            }
            .navigationBarTitle("Welcome")
        }
    }

    func signUp() {
        loading.toggle()

        RealmHelper.signUp(username: username, password: password) { result in
            DispatchQueue.main.sync {
                loading.toggle()

                switch result {
                case .failure(let error):
                    print("Signup failed: \(error)")
                    message = "Signup failed: \(error.localizedDescription)"
                case .success(let helper):
                    print("Signup successful!")
                    data.store(realm: helper.realm)
                    signedIn = true
                }
            }
        }
    }

    func signIn() {
        loading.toggle()

        RealmHelper.signIn(username: username, password: password) { result in
            // Completion handlers are not necessarily called on the UI thread.
            // This call to DispatchQueue.main.sync ensures that any changes to the UI,
            // namely disabling the loading indicator and navigating to the next page,
            // are handled on the UI thread:
            DispatchQueue.main.sync {
                loading.toggle()

                switch result {
                case .failure(let error):
                    print("Login failed: \(error)")
                    message = "Login failed: \(error.localizedDescription)"
                case .success(let helper):
                    print("Login succeeded!")
                    data.store(realm: helper.realm)
                    signedIn = true
                }
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView().environmentObject(DataStore())
    }
}
