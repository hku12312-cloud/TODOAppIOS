import SwiftUI

struct ReminderView: View {
    @ObservedObject var task: Task
    @ObservedObject var manager: TaskManager
    @Environment(\.presentationMode) var presentationMode

    @State private var reminderDate: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Set Reminder Date and Time")) {
                    DatePicker("Reminder", selection: $reminderDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationBarTitle("Set Reminder", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveReminder()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(reminderDate < Date())
            )
            .onAppear {
                // Safely unwrap and assign reminderDate when view appears
                               if let existingDate = task.reminderDate {
                                   reminderDate = existingDate
                               }
            }
        }
    }

    private func saveReminder() {
        task.reminderDate = reminderDate
        manager.saveContext()
        scheduleNotification(for: task)    // schedule the notification
    }

    
    func scheduleNotification(for task: Task) {
        let center = UNUserNotificationCenter.current()
        
        // Request permission if not done yet
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted && error == nil {
                // Create content
                let content = UNMutableNotificationContent()
                content.title = "Hey,You have a task"
                content.body = task.title ?? "You have a task reminder."
                content.sound = UNNotificationSound.default
                
                // Create trigger from reminderDate
                if let reminderDate = task.reminderDate {
                    let triggerDate = Calendar.current.dateComponents(
                        [.year, .month, .day, .hour, .minute],
                        from: reminderDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                    
                    // Create request with unique identifier
                    let request = UNNotificationRequest(
                        identifier: task.id?.uuidString ?? UUID().uuidString,
                        content: content,
                        trigger: trigger)
                    
                    // Add request
                    center.add(request) { error in
                        if let error = error {
                            print("Error scheduling notification: \(error.localizedDescription)")
                        } else {
                            print("Notification scheduled for \(reminderDate)")
                        }
                    }
                }
            } else {
                print("Notification permission denied.")
            }
        }
    }

    
}

