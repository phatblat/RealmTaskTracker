//
//  WelcomeView.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/15/20.
//

import SwiftUI

struct WelcomeView: View {
    @State private var loading = false
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        LoadingView(isShowing: $loading) {
            VStack {
                Text("Please enter a username and password.")
                    .padding()
                Form {
                    TextField("Username", text: $username)
                    SecureField("Password", text: $password)
                    Button("Sign In", action: signIn)
                }
                Button("Sign Up", action: signUp)
            }
        }
    }

    func signIn() {
        loading.toggle()
    }

    func signUp() {}
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
