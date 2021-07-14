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

    @State private var username = "Testuser"
    @State private var password = "password"
    @State private var message = "Version: \(Constants.appVersion)"

    var body: some View {
        VStack {
            if let error = error {
                Text("Error: \(error.localizedDescription)")
            }

            Text("Please enter a username and password.")
                .padding()

            Form {
                TextField("Username", text: $username)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                    .autocapitalization(UITextAutocapitalizationType.none)

                SecureField("Password", text: $password)
                    .disableAutocorrection(true)
                    .autocapitalization(UITextAutocapitalizationType.none)

                Button("Sign In", action: signIn)
                    .disabled(state.shouldIndicateActivity)

                Button("Sign Up", action: signUp)
                    .disabled(state.shouldIndicateActivity)
            }
            Text(message)
        }
    }
}

extension LoginView {
    func signUp() {
        state.signUp(username: username, password: password) { result in
            switch result {
            case .failure(let error):
                self.error = error
                message = "Signup failed: \(error.localizedDescription)"
                print(message)
            case .success():
                print("Signup successful!")
            }
        }
    }

    func signIn() {
        state.signIn(username: username, password: password) { result in
            switch result {
            case .failure(let error):
                self.error = error
                message = "Login failed: \(error.localizedDescription)"
                print(message)
            case .success(_):
                print("Login succeeded!")
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
