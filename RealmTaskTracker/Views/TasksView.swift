//
//  TasksView.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/15/20.
//

//import RealmSwift
import SwiftUI

struct TasksView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var data: DataStore
//    @EnvironmentObject var helper: RealmHelper

    @State private var showingLogoutAlert = false
    @State private var showingActionSheet = false

    private var tasks: [Task] {
        data.tasks.sorted(by: { $0._id < $1._id })
    }

    // Partition value must be of string type.
    private var partitionValue: String {
//        realm.configuration.syncConfiguration?.partitionValue?.stringValue ?? "No Realm"
        ""
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(tasks, id: \._id) { task in
                    // Make it mutable
                    var task = task
                    TaskRow(task: task.realmBinding())
                        .onTapGesture { showingActionSheet = true }
                        // FIXME: First task in list is always the one modified.
                        .actionSheet(isPresented: $showingActionSheet) {
                            var buttons: [Alert.Button] = []
                            // If the task is not in the Open state, we can set it to open. Otherwise, that action will not be available.
                            // We do this for the other two states -- InProgress and Complete.
                            if (task.statusEnum != .Open) {
                                buttons.append(.default(Text("Open"), action: {
                                    // Any modifications to managed objects must occur in a write block.
                                    // When we modify the Task's state, that change is automatically reflected in the realm.
                                    task.statusEnum = .Open
//                                    helper.updateConvertible(task)
                                }))
                            }

                            if (task.statusEnum != .InProgress) {
                                buttons.append(.default(Text("Start Progress"), action: {
                                    task.statusEnum = .InProgress
//                                    helper.updateConvertible(task)
                                }))
                            }

                            if (task.statusEnum != .Complete) {
                                buttons.append(.default(Text("Complete"), action: {
                                    task.statusEnum = .Complete
//                                    helper.updateConvertible(task)
                                }))
                            }

                            buttons.append(.cancel())

                            return ActionSheet(title: Text(task.name), message: Text("Select an action"), buttons: buttons)
                        }
                }
                .onDelete(perform: delete)
            }
//            .navigationBarTitle(helper.partitionValue)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading:
                    Button("Log Out") {
                        showingLogoutAlert = true
                    }
                    .alert(isPresented: $showingLogoutAlert) {
                        Alert(title: Text("Log Out"), message: Text(""), primaryButton: .cancel(), secondaryButton: .destructive(Text("Yes, Log Out"), action: {
                                print("Logging out...")
                                _ = RealmHelper.signOut()
                                    .receive(on: DispatchQueue.main)
                                    .sink { completion in
                                        switch completion {
                                        case .failure(let error):
                                            print("Error: ", error)
                                        case .finished:
                                            print("Logged out")
                                        }
                                        presentationMode.wrappedValue.dismiss()
                                    } receiveValue: { _ in }
                            }
                        ))
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
//            helper.deleteConvertible(task)
        }
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView().environmentObject(DataStore())
    }
}
