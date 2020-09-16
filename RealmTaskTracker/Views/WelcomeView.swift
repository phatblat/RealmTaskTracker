//
//  WelcomeView.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/15/20.
//

import RealmSwift
import SwiftUI

struct WelcomeView: View {
    @State private var loading = false
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var message: String = ""

    var body: some View {
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
                Text(message)
            }
        }
    }

    func signUp() {
        loading.toggle()

        let emailPassAuth = app.emailPasswordAuth()
        emailPassAuth.registerEmail(username, password: password, completion: { (error: Error?) in
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
        })
    }

    func signIn() {}
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
