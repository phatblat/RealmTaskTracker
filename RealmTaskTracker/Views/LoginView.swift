//
//  LoginView.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/15/20.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var state: AppState

    // Display an error if it occurs
    @State var error: Error?

    @State private var signedIn = false
    @State private var username = "Testuser"
    @State private var password = "password"
    @State private var message = "Version: \(Constants.appVersion)"

    var body: some View {
        NavigationView {
            LoadingView(isShowing: $state.shouldIndicateActivity) {
                VStack {
                    if let error = error {
                        Text("Error: \(error.localizedDescription)")
                    }
                    Text("Please enter a username and password.")
                        .padding()
                    Form {
                        TextField("Username", text: $username)
                        SecureField("Password", text: $password)
                        Button("Sign In", action: signIn)
                            .disabled(state.shouldIndicateActivity)
                        Button("Sign Up", action: signUp)
                            .disabled(state.shouldIndicateActivity)
                    }
                    NavigationLink(destination: TasksView(), isActive: $signedIn) { EmptyView () }
                    Text(message)
                }
            }
            .navigationBarTitle("Login")
        }
    }
}

extension LoginView {
    func signUp() {
        state.signUp(username: username, password: password) { result in
            DispatchQueue.main.sync {
                switch result {
                case .failure(let error):
                    message = "Signup failed: \(error.localizedDescription)"
                case .success():
                    print("Signup successful!")
                    signedIn = true
                }
            }
        }
    }

    func signIn() {
        state.signIn(username: username, password: password) { result in
            DispatchQueue.main.sync {
                switch result {
                case .failure(let error):
                    print("Login failed: \(error)")
                    message = "Login failed: \(error.localizedDescription)"
                case .success(_):
                    print("Login succeeded!")
                    signedIn = true
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppState())
    }
}
