//
//  TaskRow.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/16/20.
//

import SwiftUI

struct TaskRow: View {
    @EnvironmentObject var state: AppState

    var task: Task

    var body: some View {
        HStack {
            Text(task.name)

            Spacer()

            switch task.statusEnum {
            case .InProgress:
                Text("In Progress")
            case .Complete:
                Text("✅")
            default:
                EmptyView()
            }
        }
    }
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        TaskRow(task: Task(name: "Some Task"))
            .environmentObject(AppState())
    }
}
