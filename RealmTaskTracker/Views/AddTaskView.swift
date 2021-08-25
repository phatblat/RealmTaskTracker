//
//  AddTaskView.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/16/20.
//

import RealmSwift
import SwiftUI

struct AddTaskView: View {
    @Environment(\.realm) var realm: Realm
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var enteredText: String = ""

    var body: some View {
        Form {
            TextField("Task Name", text: $enteredText)
            Button("Save", action: add)
        }
        .navigationBarTitle("Add Task")
    }

    func add() {
        guard enteredText != "" else {
            print("Empty task, ignoring")
            return
        }

        // Create a new Task with the text that the user entered.
        let task = Task(name: enteredText)
        do {
            try realm.write {
                realm.add(task)
            }
        } catch {
            print("Error add task: \(task)")
        }

        print("Task added! \(task)")
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
    }
}
