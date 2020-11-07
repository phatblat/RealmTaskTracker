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

    /// The items in this group.
//    @ObservedObject
    var tasks: Results<Task> {
        guard let tasks = state.tasks else { fatalError() }
        return tasks
    }

    @State private var showingLogoutAlert = false
    @State private var showingActionSheet = false

    /// The button to be displayed on the top left.
    var leadingBarButton: AnyView?

    // Partition value must be of string type.
    private var partitionValue: String {
        Constants.partitionValue
    }

    var body: some View {
        NavigationView {
            // The list shows the items in the realm.
            List {
                // ⚠️ ALWAYS freeze a Realm list while iterating in a SwiftUI
                // View's ForEach(). Otherwise, unexpected behavior will occur,
                // especially when deleting object from the list.
                ForEach(tasks.freeze()) { frozenTask in
                    TaskRow(task: tasks.realm!.resolve(ThreadSafeReference(to: frozenTask))!)
                        .onTapGesture { showingActionSheet = true }
                        // FIXME: First task in list is always the one modified.
                        .actionSheet(isPresented: $showingActionSheet) {
                            var buttons: [Alert.Button] = []
                            // If the task is not in the Open state, we can set it to open. Otherwise, that action will not be available.
                            // We do this for the other two states -- InProgress and Complete.
                            if (frozenTask.statusEnum != .Open) {
                                buttons.append(.default(Text("Open"), action: {
                                    // Any modifications to managed objects must occur in a write block.
                                    // When we modify the Task's state, that change is automatically reflected in the realm.
//                                    task.statusEnum = .Open
//                                    data.taskDB.update(task)
                                }))
                            }

                            if (frozenTask.statusEnum != .InProgress) {
                                buttons.append(.default(Text("Start Progress"), action: {
//                                    task.statusEnum = .InProgress
//                                    data.taskDB.update(task)
                                }))
                            }

                            if (frozenTask.statusEnum != .Complete) {
                                buttons.append(.default(Text("Complete"), action: {
//                                    task.statusEnum = .Complete
//                                    data.taskDB.update(task)
                                }))
                            }

                            buttons.append(.cancel())

                            return ActionSheet(title: Text(frozenTask.name), message: Text("Select an action"), buttons: buttons)
                        }
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

    // FIXME: Works to delete, but crashes as list is refreshed.
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let task = tasks[index]
            let realm = try! Realm()
//            try! realm.write {
//                realm.delete(task)
//            }
        }
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView()
            .environmentObject(AppState())
    }
}
