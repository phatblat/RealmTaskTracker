//
//  ActivityIndicator.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 11/9/20.
//

import SwiftUI

// MARK: UIActivityIndicatorView Wrapper

/// Simple activity indicator to telegraph that the app is active in the background.
struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        return UIActivityIndicatorView(style: .large)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        (uiView as! UIActivityIndicatorView).startAnimating()
    }
}

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator()
    }
}
