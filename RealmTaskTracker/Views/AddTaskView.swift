//
//  AddTaskView.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/16/20.
//

import RealmSwift
import SwiftUI

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var realmWrapper: RealmWrapper

    @State private var enteredText: String = ""

    private var realm: Realm {
        guard let realm = realmWrapper.realm else { fatalError("No Realm!") }
        return realm
    }

    private var partitionValue: String {
        realm.configuration.syncConfiguration?.partitionValue?.stringValue ?? "No Realm"
    }

    var body: some View {
        Form {
            TextField("Task Name", text: $enteredText)
            Button("Save") {
                guard enteredText != "" else {
                    print("Empty task, ignoring")
                    return
                }

                // Create a new Task with the text that the user entered.
                let task = Task(name: enteredText).realmMap()

                // Any writes to the Realm must occur in a write block.
                try! realm.write {
                    // Add the Task to the Realm. That's it!
                    realm.add(task)
                }
                print("Task added! \(task)")
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationBarTitle("Add Task")
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
    }
}
