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

    /// All tasks.
    @ObservedObject var tasks: RealmSwift.List<Task>

    @State private var showingActionSheet = false
    @State private var editTask: Task? = nil

    var body: some View {
        NavigationView {
            List {
                // ⚠️ ALWAYS freeze a Realm list while iterating in a SwiftUI
                // View's ForEach(). Otherwise, unexpected behavior will occur,
                // especially when deleting object from the list.
                ForEach(tasks.freeze()) { frozenTask in
                    // "Thaw" the task so that it can be mutated
                    let thawedTask = thaw(object: frozenTask, in: tasks.realm)

                    TaskRow(task: thawedTask)
                        .onTapGesture {
                            editTask = thawedTask
                            showingActionSheet = true
                        }
                        .actionSheet(isPresented: $showingActionSheet, content: editTaskStatus)
                }
                .onDelete(perform: delete)
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
        if (task.statusEnum != .Open) {
            buttons.append(.default(Text("Open"), action: {
                // Any modifications to managed objects must occur in a write block.
                // When we modify the Task's state, that change is automatically reflected in the realm.
                try! tasks.realm?.write {
                    task.statusEnum = .Open
                }
            }))
        }

        if (task.statusEnum != .InProgress) {
            buttons.append(.default(Text("Start Progress"), action: {
                try! tasks.realm?.write {
                    task.statusEnum = .InProgress
                }
            }))
        }

        if (task.statusEnum != .Complete) {
            buttons.append(.default(Text("Complete"), action: {
                try! tasks.realm?.write {
                    task.statusEnum = .Complete
                }
            }))
        }

        buttons.append(.cancel())

        return ActionSheet(title: Text(task.name), message: Text("Select an action"), buttons: buttons)
    }

    /// Deletes the given item.
    func delete(at offsets: IndexSet) {
        guard let tasks = state.tasks else { fatalError("No tasks in state") }

        for offset in offsets {
            guard let realm = tasks.realm else {
                // TODO: Not sure how to remove from a result
                //  tasks.remove(at: offsets.first!)
                return
            }

            do {
                try realm.write {
                    realm.delete(tasks[offset])
                }
            } catch {
                print("Error deleting task at offset: \(offset)")
            }
        }
    }

    /// "Thaws" the realm object so that it can be mutated/updated.
    func thaw<T: Object>(object: T, in realm: Realm?) -> T {
        guard let thawedObject = realm?.resolve(ThreadSafeReference(to: object)) else {
            fatalError("Failed to thaw frozen object \(object)")
        }
        return thawedObject
    }
}

//struct TasksView_Previews: PreviewProvider {
//    static var previews: some View {
//        TasksView()
//            .environmentObject(AppState())
//    }
//}
