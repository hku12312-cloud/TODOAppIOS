// ToDoApp.swift

// ContentView.swift
import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)],
        animation: .default)
    private var tasks: FetchedResults<Task>
    
    @StateObject private var manager: TaskManager
    @State private var newTaskTitle: String = ""
    @State private var editingTask: Task? = nil
    @State private var editingTitle: String = ""
    @State private var editingTasks: Task? = Task()
    init() {
        let context = PersistenceController.shared.container.viewContext
        _manager = StateObject(wrappedValue: TaskManager(context: context))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Add new task...", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: addTask) {
                        Image(systemName: "plus")
                            .padding(8)
                    }
                    .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                
                List {
                    ForEach(tasks) { task in
                        HStack {
                            Button(action: { manager.toggleComplete(task) }) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            VStack(alignment: .leading) {
                                Text(task.title ?? "Untitled")
                                    .strikethrough(task.isCompleted, color: .primary)
                                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                                if let date = task.createdAt {
                                    Text(date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            Button(action: {
                                editingTask = task
                                editingTitle = task.title ?? ""
                            }) {
                                Image(systemName: "pencil")
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("To‑Do")
            .toolbar {
                HStack{
                    EditButton()
                    Spacer()
                   
                }
                
            }
            .sheet(item: $editingTask) { task in
                EditTaskView(task: task, manager: manager, isPresented: Binding(get: { editingTask != nil }, set: { if !$0 { editingTask = nil } }))
            }
            .onAppear {
                requestNotificationPermission()
            }
        }
    }
    
    private func addTask() {
        manager.addTask(title: newTaskTitle)
        newTaskTitle = ""
    }
    
    private func deleteItems(offsets: IndexSet) {
        offsets.map { tasks[$0] }.forEach { manager.deleteTask($0) }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }

}

import SwiftUI
import CoreData

struct ReminderButtonView: View {
    @ObservedObject var task: Task
    @ObservedObject var manager: TaskManager
    
    @State private var isShowingReminderView = false
    
    var body: some View {
        Button(action: {
            isShowingReminderView = true
        }) {
            Image(systemName: "bell")
                .imageScale(.large)
                .padding()
        }
        // Navigation to ReminderView
        .sheet(isPresented: $isShowingReminderView) {
            ReminderView(task: task, manager: manager)
        }
    }
}
