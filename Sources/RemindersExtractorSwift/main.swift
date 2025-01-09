/// RemindersExtractorSwift
/// A command-line tool that extracts reminders from the "Today" smart list in Apple Reminders and exports them to a markdown file.
/// Uses the EventKit framework for reliable access to the Reminders database.

import Foundation
import EventKit

print("Starting Reminders Extraction...")

// Initialize the EventKit event store
// This is the main entry point for accessing the Reminders database
let eventStore = EKEventStore()

// Request access to reminders
// This will prompt the user for permission if not already granted
// The closure is called after the user grants or denies access
eventStore.requestAccess(to: .reminder) { granted, error in
    guard granted else {
        print("Access to reminders was denied")
        if let error = error {
            print("Error: \(error)")
        }
        exit(1)
    }
    
    // Get all reminder lists (calendars)
    // This includes both local lists and those synced via iCloud
    let calendars = eventStore.calendars(for: .reminder)
    print("Found \(calendars.count) reminder lists")
    
    // Create predicates to match the "Today" smart list behavior
    // This includes:
    // 1. Reminders due today or overdue
    // 2. Incomplete reminders
    let calendar = Calendar.current
    let startDate = calendar.startOfDay(for: Date())
    let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
    
    // Get incomplete reminders that are due today or overdue
    let predicate = eventStore.predicateForIncompleteReminders(withDueDateStarting: nil,
                                                             ending: endDate,
                                                             calendars: calendars)
    
    // Fetch reminders
    eventStore.fetchReminders(matching: predicate) { reminders in
        guard let reminders = reminders else {
            print("No reminders found or error occurred")
            exit(1)
        }
        
        // Convert reminders to a simpler format for output
        // For each reminder, we extract:
        // - name (title): The reminder text, defaulting to "Untitled" if nil
        // - dueDate: The reminder's due date (optional)
        // - completed: Whether the reminder is marked as done
        // - listName: The name of the list containing this reminder
        let reminderData = reminders.map { reminder in
            (
                name: reminder.title ?? "Untitled",
                dueDate: reminder.dueDateComponents?.date,
                completed: reminder.isCompleted,
                listName: reminder.calendar.title
            )
        }
        
        // Print a summary of found reminders
        print("Found \(reminderData.count) reminders in Today list")
        
        // Create the markdown file
        // Filename includes timestamp for uniqueness
        let timestamp = DateFormatter()
        timestamp.dateFormat = "yyyyMMdd_HHmmss"
        let filename = "today_reminders_\(timestamp.string(from: Date())).md"
        
        // Generate markdown content
        // Format:
        // - Title
        // - Simple bulleted list of reminders
        var markdown = "# Today's Reminders\n\n"
        
        // Add each reminder as a bullet point
        // For long lines, ensure they wrap nicely in markdown
        for reminder in reminderData {
            // Split long lines at 80 characters, preserving words
            let words = reminder.name.split(separator: " ")
            var currentLine = "- "
            
            for word in words {
                let potentialLine = currentLine + (currentLine.hasSuffix(" ") ? "" : " ") + word
                
                if potentialLine.count <= 80 {
                    currentLine = potentialLine
                } else {
                    markdown += currentLine + "\n"
                    currentLine = "  " + String(word)  // Indent continuation lines
                }
            }
            
            markdown += currentLine + "\n"  // Add the last line
        }
        
        // Write the markdown file
        // Uses atomic write to prevent partial files
        do {
            try markdown.write(toFile: filename, atomically: true, encoding: .utf8)
            print("Created markdown file: \(filename)")
        } catch {
            print("Error writing markdown file: \(error)")
        }
        
        exit(0)
    }
}

// Keep the script running until completion
// This is necessary because the EventKit operations are asynchronous
RunLoop.main.run()
