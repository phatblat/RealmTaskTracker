//
//  TextAlert.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/16/20.
//
//  https://www.objc.io/blog/2020/04/21/swiftui-alert-with-textfield/
//  https://gist.github.com/chriseidhof/cb662d2161a59a0cd5babf78e3562272

// Unused. I couldn't get this to work in Xcode 12 GM.

import SwiftUI

extension UIAlertController {
    convenience init(alert: TextAlert) {
        self.init(title: alert.title, message: nil, preferredStyle: .alert)
        addTextField { $0.placeholder = alert.placeholder }
        addAction(UIAlertAction(title: alert.cancel, style: .cancel) { _ in
            alert.action(nil)
        })
        let textField = self.textFields?.first
        addAction(UIAlertAction(title: alert.accept, style: .default) { _ in
            alert.action(textField?.text)
        })
    }
}

struct AlertWrapper<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let alert: TextAlert
    let content: Content

    func makeUIViewController(context: UIViewControllerRepresentableContext<AlertWrapper>) -> UIHostingController<Content> {
        UIHostingController(rootView: content)
    }

    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: UIViewControllerRepresentableContext<AlertWrapper>) {
        uiViewController.rootView = content
        if isPresented && uiViewController.presentedViewController == nil {
            var alert = self.alert
            alert.action = {
                self.isPresented = false
                self.alert.action($0)
            }
            context.coordinator.alertController = UIAlertController(alert: alert)
            uiViewController.present(context.coordinator.alertController!, animated: true)
        }
        if !isPresented && uiViewController.presentedViewController == context.coordinator.alertController {
            uiViewController.dismiss(animated: true)
        }
    }

    final class Coordinator {
        var alertController: UIAlertController?
        init(_ controller: UIAlertController? = nil) {
            self.alertController = controller
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
}

struct TextAlert {
    var title: String
    var placeholder: String = ""
    var accept: String = "OK"
    var cancel: String = "Cancel"
    var action: (String?) -> Void
}

extension View {
    func alert(isPresented: Binding<Bool>, _ alert: TextAlert) -> some View {
        AlertWrapper(isPresented: isPresented, alert: alert, content: self)
    }
}

struct ContentView: View {
    @State var showsAlert = false
    var body: some View {
        VStack {
            Text("Hello, World!")
            Button("alert") {
                self.showsAlert = true
            }
        }
        .alert(isPresented: $showsAlert, TextAlert(title: "Title", action: {
            print("Callback \($0 ?? "<cancel>")")
        }))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
