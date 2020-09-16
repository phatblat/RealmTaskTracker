//
//  TasksView.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/15/20.
//

import RealmSwift
import SwiftUI

struct TasksView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var realmWrapper: RealmWrapper

    @State private var showingLogoutAlert = false
    @State private var showingAddAlert = false

    private var realm: Realm {
        guard let realm = realmWrapper.realm else { fatalError("No Realm!") }
        return realm
    }

    private var tasks: Results<Task> {
        // Access all tasks in the realm, sorted by _id so that the ordering is defined.
        // Only tasks with the project ID as the partition key value will be in the realm.
        realm.objects(Task.self).sorted(byKeyPath: "_id")
    }

    private var partitionValue: String {
        realm.configuration.syncConfiguration?.partitionValue?.stringValue ?? "No Realm"
    }

    var body: some View {
        List {
            ForEach(tasks) { task in
                Text(task.name)
            }
        }
        // Partition value must be of string type.
        .navigationBarTitle(partitionValue)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading:
                Button("Log Out") {
                    showingLogoutAlert = true
                }
                .alert(isPresented: $showingLogoutAlert) {
                    Alert(title: Text("Log Out"), message: Text(""), primaryButton: .cancel(), secondaryButton: .destructive(Text("Yes, Log Out"), action: {
                            print("Logging out...");
                            app.currentUser()?.logOut() { error in
                                guard error == nil else {
                                    print("Error logging out: \(error!)")
                                    return
                                }
                                DispatchQueue.main.sync {
                                    print("Logged out!")
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        })
                    )
                },
            trailing:
                Button("+") {
                    showingAddAlert = true
                }
                .alert(isPresented: $showingAddAlert, TextAlert(title: "Add Task", action: {
                    // When the user clicks the add button, present them with a dialog to enter the task name.
                    print("Callback \($0 ?? "<cancel>")")

//                    let textField = alertController.textFields![0] as UITextField

                    // Create a new Task with the text that the user entered.
                    let task = Task(partition: partitionValue, name: "New Task")

                    // Any writes to the Realm must occur in a write block.
                    try! realm.write {
                        // Add the Task to the Realm. That's it!
                        realm.add(task)
                    }
                }))
        )
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView()
    }
}
