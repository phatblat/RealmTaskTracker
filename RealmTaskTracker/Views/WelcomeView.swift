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
    @State private var loading = false
    @State private var username = "Testuser"
    @State private var password = "password"
    @State private var message = ""
    @State private var signedIn = false

    @ObservedObject private var realmWrapper = RealmWrapper()

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
        .environmentObject(realmWrapper)
    }

    func signUp() {
        loading.toggle()

        let emailPassAuth = app.emailPasswordAuth()
        emailPassAuth.registerUser(email: username, password: password) { (error: Error?) in
            DispatchQueue.main.sync {
                loading.toggle()

                guard error == nil else {
                     print("Signup failed: \(error!)")
                     message = "Signup failed: \(error!.localizedDescription)"
                     return
                }
                print("Signup successful!")

                // Registering just registers. Now we need to sign in,
                // but we can reuse the existing username and password.
                message = "Signup successful! Signing in..."
                signIn()
            }
        }
    }

    func signIn() {
        print("Log in as user: \(username)")
        loading.toggle()

        let credentials = Credentials(email: username, password: password)
        app.login(credentials: credentials) { (user: RealmSwift.User?, error: Error?) in
            // Completion handlers are not necessarily called on the UI thread.
            // This call to DispatchQueue.main.sync ensures that any changes to the UI,
            // namely disabling the loading indicator and navigating to the next page,
            // are handled on the UI thread:
            DispatchQueue.main.sync {
                loading.toggle()
                guard error == nil else {
                   // Auth error: user already exists? Try logging in as that user.
                   print("Login failed: \(error!)");
                   message = "Login failed: \(error!.localizedDescription)"
                   return
                }

                print("Login succeeded!")

                // For the first phase of the tutorial, go directly to the Tasks page
                // for the hardcoded project ID "My Project".
                // This will use a common project and demonstrate sync.
                let partitionValue = "My Project"

                // Open a realm.
                realmWrapper.realm = try! Realm(configuration: user!.configuration(partitionValue: partitionValue))

                signedIn = true
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
