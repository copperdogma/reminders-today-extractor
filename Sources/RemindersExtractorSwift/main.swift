/// RemindersExtractorSwift
/// A command-line tool that extracts reminders from the "Today" smart list in Apple Reminders and exports them to a markdown file.
/// Uses the EventKit framework for reliable access to the Reminders database.

import Foundation
import EventKit
import ArgumentParser

@main
struct RemindersExtractor: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Extract today's reminders to a markdown file.",
        discussion: """
            Extracts all reminders from your Today list and saves them to a markdown file.
            Requires access to your Reminders, which you'll need to grant in System Settings.
            """
    )
    
    mutating func run() async throws {
        print("Starting Reminders Extraction...")

        // Initialize the EventKit event store
        let eventStore = EKEventStore()
        
        // Request access to reminders using async/await
        let granted = try await eventStore.requestAccess(to: .reminder)
        guard granted else {
            print("Access to reminders was denied")
            throw ValidationError("Access to reminders was denied. Please grant access in System Settings > Privacy & Security > Reminders")
        }
        
        // Get all reminder lists (calendars) and create an immutable copy
        let calendarsCopy = eventStore.calendars(for: .reminder).map { $0 }
        let calendarCount = calendarsCopy.count
        
        print("Found \(calendarCount) reminder lists")
        
        // Create predicates to match the "Today" smart list behavior
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        // Get incomplete reminders that are due today or overdue
        let predicate = eventStore.predicateForIncompleteReminders(withDueDateStarting: nil,
                                                                 ending: endDate,
                                                                 calendars: calendarsCopy)
        
        // Fetch reminders using async/await
        let reminders = try await withCheckedThrowingContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { fetchedReminders in
                if let fetchedReminders = fetchedReminders {
                    // Create a copy of the reminders data to avoid data races
                    let remindersCopy = fetchedReminders.map { reminder in
                        reminder.title ?? "Untitled"
                    }
                    continuation.resume(returning: remindersCopy)
                } else {
                    continuation.resume(throwing: NSError(domain: "RemindersExtractor", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch reminders"]))
                }
            }
        }
        
        print("Found \(reminders.count) reminders in Today list")
        
        // Create the markdown file
        let timestamp = DateFormatter()
        timestamp.dateFormat = "yyyyMMdd_HHmmss"
        let filename = "today_reminders_\(timestamp.string(from: Date())).md"
        
        // Generate markdown content
        var markdown = "# Today's Reminders (\(reminders.count))\n\n"
        
        // Add each reminder as a bullet point
        for reminder in reminders {
            markdown += "- \(reminder)\n"
        }
        
        // Write the markdown file
        do {
            try markdown.write(toFile: filename, atomically: true, encoding: .utf8)
            print("Created markdown file: \(filename)")
        } catch {
            print("Error writing markdown file: \(error)")
            throw error
        }
    }
}

struct ValidationError: Error, CustomStringConvertible {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var description: String {
        message
    }
}

