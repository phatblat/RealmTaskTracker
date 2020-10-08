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

//    @EnvironmentObject var helper: RealmHelper

    @State private var enteredText: String = ""

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
//                helper.create(task)
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
