//
//  LoginView.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/15/20.
//

import RealmSwift
import SwiftUI

struct LoginView: View {
    // Display an error if it occurs
    @State var error: Error?
    @State var navigationTag: String?

    @State private var username = "Testuser"
    @State private var password = "password"
    @State private var message = "Version: \(Constants.appVersion)"

    let account = AccountHelper()

    var body: some View {
        NavigationView {
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

                    Button("Sign In") {
                        signIn { user in
                            navigationTag = "asyncOpen"
                        }
                    }

//                    .disabled(state.shouldIndicateActivity)

                    Button("Sign Up") {
                        signUp { user in
                            navigationTag = "asyncOpen"
                        }
                    }
//                    .disabled(state.shouldIndicateActivity)
                }
                Text(message)
                NavigationLink(destination: LazyView(AsyncOpenView()), tag: "asyncOpen", selection: $navigationTag, label: { EmptyView() })
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

extension LoginView {
    func signUp(completion: @escaping (RealmSwift.User) -> Void) {
        account.signUp(username: username, password: password) { result in
            switch result {
            case .failure(let error):
                self.error = error
                message = "Signup failed: \(error.localizedDescription)"
                print(message)
            case .success(let user):
                print("Signup and login successful")
                completion(user)
            }
        }
    }

    func signIn(completion: @escaping (RealmSwift.User) -> Void) {
        account.signIn(username: username, password: password) { result in
            switch result {
            case .failure(let error):
                self.error = error
                message = "Login failed: \(error.localizedDescription)"
                print(message)
            case .success(let user):
                print("Login succeeded")
                completion(user)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
