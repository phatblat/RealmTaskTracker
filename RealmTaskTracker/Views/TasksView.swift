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
            if let tasks = state.tasks {
                // The list shows the items in the realm.
                List {
                    // ⚠️ ALWAYS freeze a Realm list while iterating in a SwiftUI
                    // View's ForEach(). Otherwise, unexpected behavior will occur,
                    // especially when deleting object from the list.
                    ForEach(tasks.freeze()) { frozenTask in
                        
                        // "Thaw" the task so that it can be mutated
                        let thawedTask = thaw(object: frozenTask, in: tasks.realm)

                        TaskRow(task: thawedTask)
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
            else {
                // no tasks
                Text("Loading tasks...")
            }
        }
        .navigationBarHidden(true)
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
