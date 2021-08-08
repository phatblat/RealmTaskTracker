//
//  TasksView.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/15/20.
//

import RealmSwift
import SwiftUI

/// Screen containing a list of tasks. Implements functionality for adding, rearranging, and deleting tasks.
struct TasksView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @EnvironmentObject var state: AppState

    /// All of the user's tasks.
    @ObservedResults(Task.self) var tasks

    @State private var showingActionSheet = false
    @State private var editTask: Task? = nil

    var body: some View {
        NavigationView {
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
//                .onMove(perform: $tasks.move)
            }
            .navigationBarTitle("Tasks", displayMode: .large)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading:
                    LogoutButton(),
                trailing:
                    NavigationLink(destination: AddTaskView()) {
                        Text("+")
                    }
                    .animation(.easeInOut(duration: 3.0))
            )
        }
        .navigationBarHidden(true)
    }

    /// Builds an action sheet to toggle the selected task's status.
    func editTaskStatus() -> ActionSheet {
        guard var task = editTask else { fatalError("Error: no task saved to edit!") }

        var buttons: [Alert.Button] = []

        // If the task is not in the Open state, we can set it to open. Otherwise, that action will not be available.
        // We do this for the other two states -- InProgress and Complete.
        if (task.status != .Open) {
            buttons.append(.default(Text("Open"), action: {
                // Any modifications to managed objects must occur in a write block.
                // When we modify the Task's state, that change is automatically reflected in the realm.
                try! tasks.realm?.write {
                    task.status = .Open
                }
            }))
        }

        if (task.status != .InProgress) {
            buttons.append(.default(Text("Start Progress"), action: {
                try! tasks.realm?.write {
                    task.status = .InProgress
                }
            }))
        }

        if (task.status != .Complete) {
            buttons.append(.default(Text("Complete"), action: {
                try! tasks.realm?.write {
                    task.status = .Complete
                }
            }))
        }

        buttons.append(.cancel())

        return ActionSheet(title: Text(task.name), message: Text("Select an action"), buttons: buttons)
    }
}

//struct TasksView_Previews: PreviewProvider {
//    static var previews: some View {
//        TasksView()
//            .environmentObject(AppState())
//    }
//}
