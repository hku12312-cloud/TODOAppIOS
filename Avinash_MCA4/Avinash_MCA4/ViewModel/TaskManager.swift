//
//  TaskManager.swift
//  Avinash_MCA4
//
//  Created by Sahil Sharma on 30/11/25.
//

import Foundation
import SwiftUI
import Foundation
import CoreData
import Combine

/// Observable class to perform CRUD operations on Task
class TaskManager: ObservableObject {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addTask(title: String) {
        let newTask = Task(context: context)
        newTask.id = UUID()
        newTask.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        newTask.isCompleted = false
        newTask.createdAt = Date()
        saveContext()
    }
    
    func deleteTask(_ task: Task) {
        context.delete(task)
        saveContext()
    }
    
    func toggleComplete(_ task: Task) {
        task.isCompleted.toggle()
        saveContext()
    }
    
    func updateTitle(_ task: Task, newTitle: String) {
        task.title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        saveContext()
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    
}
