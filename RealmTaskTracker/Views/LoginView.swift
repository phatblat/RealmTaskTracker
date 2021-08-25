//
//  LoginView.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/15/20.
//

import RealmSwift
import SwiftUI

struct LoginView: View {
    @State var navigationTag: String?

    @State private var username = "Testuser"
    @State private var password = "password"
    @State private var message = "Version: \(Constants.appVersion)"

    @ObservedObject var user = UserPublisher()

    var body: some View {
        NavigationView {
            VStack {
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

                    /*
                    FIXME: Re-enable once Testuser's ID is no longer hard-coded as the partition value.
                    Button("Sign Up") {
                        signUp { user in
                            navigationTag = "asyncOpen"
                        }
                    }
                    */
                }
                Text(message)
                NavigationLink(destination: LazyView(AsyncOpenView()),
                               tag: "asyncOpen",
                               selection: $navigationTag,
                               label: { EmptyView() })
                    .onReceive(user, perform: { _ in
                        // Auto-navigate to the AsyncOpenView when already logged in.
                        navigationTag = "asyncOpen"
                    })
            }
            .navigationBarTitle("Login", displayMode: .large)
            .navigationBarBackButtonHidden(true)
        }
        .environment(\.partitionValue, user.$paritionValue as? PartitionValue)
    }
}

extension LoginView {
    func signUp(completion: @escaping (User) -> Void) {
        user.signUp(username: username, password: password) { result in
            switch result {
            case .failure(let error):
                message = "Signup failed: \(error.localizedDescription)"
                print(message)
            case .success(let user):
                print("Signup and login successful")
                completion(user)
            }
        }
    }

    func signIn(completion: @escaping (User) -> Void) {
        user.signIn(username: username, password: password) { result in
            switch result {
            case .failure(let error):
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
