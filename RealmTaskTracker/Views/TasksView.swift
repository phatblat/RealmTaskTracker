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

    private var realm: Realm {
        guard let realm = realmWrapper.realm else { fatalError("No Realm!") }
        return realm
    }

    private var tasks: Results<Task> {
        // Access all tasks in the realm, sorted by _id so that the ordering is defined.
        // Only tasks with the project ID as the partition key value will be in the realm.
        realm.objects(Task.self).sorted(byKeyPath: "_id")
    }

    // Partition value must be of string type.
    private var partitionValue: String {
        realm.configuration.syncConfiguration?.partitionValue?.stringValue ?? "No Realm"
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(tasks, id: \._id) { task in
                    Text(task.name)
                }
                .onDelete(perform: delete)
            }
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
                                    print("Logged out!")
                                    DispatchQueue.main.sync {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            })
                        )
                    },
                trailing:
                    NavigationLink(destination: AddTaskView()) {
                        Text("+")
                    }
                    .animation(.easeInOut(duration: 3.0))
            )
        }
        .navigationBarHidden(true)
    }

    // FIXME: Works to delete, but crashes as list is refreshed.
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let task = tasks[index]
            // All modifications to a realm must happen in a write block.
            try! realm.write {
                // Delete the Task.
                realm.delete(task)
            }
        }

    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView()
    }
}
