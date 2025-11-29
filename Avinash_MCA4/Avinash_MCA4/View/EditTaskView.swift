//
//  EditTaskView.swift
//  Avinash_MCA4
//
//  Created by Sahil Sharma on 30/11/25.
//

import Foundation

// EditTaskView.swift
import SwiftUI

struct EditTaskView: View {
    @ObservedObject var task: Task
    @ObservedObject var manager: TaskManager
    @State private var title: String
    @Binding var isPresented: Bool
    @State private var showingReminderView = false
    init(task: Task, manager: TaskManager, isPresented: Binding<Bool>) {
        self.task = task
        self.manager = manager
        self._title = State(initialValue: task.title ?? "")
        self._isPresented = isPresented
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task")) {
                    TextField("Title", text: $title)
                }
                Section {
                    Toggle("Completed", isOn: Binding(get: { task.isCompleted }, set: { newVal in manager.toggleComplete(task) }))
                    Button(action: {
                                   showingReminderView = true
                               }) {
                                   HStack {
                                       Image(systemName: "bell")
                                       Text("Set Reminder")
                                   }
                               }
                           
                }
            }
            .navigationBarTitle("Edit Task", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") { isPresented = false }, trailing: Button("Save") {
                manager.updateTitle(task, newTitle: title)
                isPresented = false
            }.disabled(title.trimmingCharacters(in: .whitespaces).isEmpty))
            .sheet(isPresented: $showingReminderView) {
                       ReminderView(task: task, manager: manager)
                   }
        }
    }
}


/*
 Instructions:
 1. In Xcode create a new SwiftUI App project.
 2. Add a new Core Data model file named "ToDoModel.xcdatamodeld".
 - Create an entity named "Task" with these attributes:
 - id: UUID (Optional: No)
 - title: String (Optional: Yes)
 - isCompleted: Boolean (Default: NO)
 - createdAt: Date (Optional: Yes)
 3. Add the Swift files above into your project.
 4. Make sure PersistenceController uses the same model name "ToDoModel".
 5. Run on simulator/device. The app supports Add, Delete, Update (edit), Toggle complete and persists using Core Data.

 */
