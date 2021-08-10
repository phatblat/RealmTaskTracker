//
//  ListView.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/15/20.
//

import RealmSwift
import SwiftUI

/// Screen containing a list of tasks. Implements functionality for adding, rearranging, and deleting tasks.
struct ListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    /// All of the user's tasks.
    @ObservedResults(Task.self) var tasks

    @State private var showingActionSheet = false

    /// Selected task for updating status.
    @StateRealmObject var editTask: Task

    var body: some View {
        List {
            ForEach(tasks) { task in
                TaskRow(task: task)
                    .onTapGesture {
                        editTask = task
                        showingActionSheet = true
                    }
                    .actionSheet(isPresented: $showingActionSheet, content: editTaskStatus)
            }
            .onDelete(perform: $tasks.remove)
//            .onMove(perform: $tasks.move)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("Tasks", displayMode: .large)
        .navigationBarItems(
            leading:
                LogoutButton() {
                    presentationMode.wrappedValue.dismiss()
                },
            trailing:
                NavigationLink(destination: AddTaskView()) {
                    Text("+")
                }
                .animation(.easeInOut(duration: 3.0))
        )
    }

    /// Builds an action sheet to toggle the selected task's status.
    func editTaskStatus() -> ActionSheet {
        var buttons: [Alert.Button] = []

        // If the task is not in the Open state, we can set it to open. Otherwise, that action will not be available.
        // We do this for the other two states -- InProgress and Complete.
        if (editTask.status != .Open) {
            buttons.append(.default(Text("Open"), action: {
                self.setTaskStatus(newStatus: .Open)
            }))
        }

        if (editTask.status != .InProgress) {
            buttons.append(.default(Text("Start Progress"), action: {
                self.setTaskStatus(newStatus: .InProgress)
            }))
        }

        if (editTask.status != .Complete) {
            buttons.append(.default(Text("Complete"), action: {
                self.setTaskStatus(newStatus: .Complete)
            }))
        }

        buttons.append(.cancel())

        return ActionSheet(title: Text(editTask.name), message: Text("Select an action"), buttons: buttons)
    }

    /// Sets editTask to the given status. The task and its realm are fozen and must be thawed to change.
    /// - Parameter newStatus: TaskStatus to set
    func setTaskStatus(newStatus: TaskStatus) {
        if let realm = tasks.realm?.thaw() {
            do {
                // Any modifications to managed objects must occur in a write block.
                // When we modify the Task's state, that change is automatically reflected in the realm.
                try realm.write {
                    if let task = editTask.thaw() {
                        task.status = newStatus
                    }
                }
            } catch {
                debugPrint("Error updating task status: \(error)")
            }
        }
    }

}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(editTask: Task())
            .navigationBarTitle("Tasks")
            .environment(\.realm, MockRealms.previewRealm)
    }
}
