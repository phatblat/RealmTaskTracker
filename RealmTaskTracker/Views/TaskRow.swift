//
//  TaskRow.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/16/20.
//

import RealmSwift
import SwiftUI

struct TaskRow: View {
    @ObservedRealmObject var task: Task

    var body: some View {
        HStack {
            Text(task.name)

            Spacer()

            switch task.status {
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
        TaskRow(task: Task(name: "☑️ Some Task"))
    }
}
