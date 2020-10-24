//
//  WelcomeView.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/15/20.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var model: DataModel

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
}

extension WelcomeView {
    func signUp() {
        loading.toggle()

        model.signUp(username: username, password: password) { result in
            DispatchQueue.main.sync {
                loading.toggle()

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
        loading.toggle()

        model.signIn(username: username, password: password) { result in
            DispatchQueue.main.sync {
                loading.toggle()

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

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(DataModel())
    }
}
