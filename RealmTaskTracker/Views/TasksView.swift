//
//  TasksView.swift
//  RealmTaskTracker
//
//  Created by Ben Chatelain on 9/15/20.
//

import RealmSwift
import SwiftUI

struct TasksView: View {
    @EnvironmentObject var realmWrapper: RealmWrapper

    var body: some View {
        NavigationView {
            Text("Hello, World!")
                .navigationBarTitle(realmWrapper.realm?.configuration.description ?? "No Realm")
        }
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView()
    }
}
