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

    @EnvironmentObject var state: AppState

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

        guard let tasks = state.tasks else { fatalError("Unable to add task without results!") }

        guard let realm = tasks.realm else {
            // TODO: Not sure how to remove from a result
            //  tasks.remove(at: offsets.first!)
            return
        }

        // Create a new Task with the text that the user entered.
        let task = Task(name: enteredText)
        do {
            try realm.write {
                realm.add(task)
                if let user = state.appUser {
                    user.tasks.append(task)
                }
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
