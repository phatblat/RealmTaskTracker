//
//  ErrorView.swift
//  ErrorView
//
//  Created by Ben Chatelain on 8/9/21.
//

import SwiftUI

struct ErrorView: View {

    @State var error: Error

    var body: some View {
        VStack(spacing: 20) {
            Text("Error")
            Text(error.localizedDescription)
        }
        .padding()
    }
}

enum MockError: Error {
    case example
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(error: MockError.example)
    }
}
