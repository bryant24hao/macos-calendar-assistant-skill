import EventKit
import Foundation

let store = EKEventStore()
let calendar = Calendar.current
let dateFormatter = ISO8601DateFormatter()
dateFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withTimeZone]

func parseDate(_ iso: String) -> Date? {
    return dateFormatter.date(from: iso)
}

if CommandLine.arguments.count < 5 {
    print("Usage: move_event.swift <Title> <Calendar> <NewStartISO> <DurationMinutes>")
    exit(1)
}

let targetTitle = CommandLine.arguments[1]
let targetCalendarName = CommandLine.arguments[2]
let newStartISO = CommandLine.arguments[3]
let durationMinutes = Double(CommandLine.arguments[4])!

guard let newStartDate = parseDate(newStartISO) else {
    print("Error: Invalid date format (use ISO8601)")
    exit(1)
}

let semaphore = DispatchSemaphore(value: 0)

store.requestAccess(to: .event) { granted, error in
    guard granted else {
        print("Access denied")
        semaphore.signal()
        return
    }
    
    let calendars = store.calendars(for: .event)
    guard let cal = calendars.first(where: { $0.title == targetCalendarName }) else {
        print("Error: Calendar '\(targetCalendarName)' not found")
        semaphore.signal()
        return
    }

    // Search today
    let now = Date()
    let startSearch = calendar.startOfDay(for: now)
    let endSearch = calendar.date(byAdding: .day, value: 1, to: startSearch)!
    
    let predicate = store.predicateForEvents(withStart: startSearch, end: endSearch, calendars: [cal])
    let events = store.events(matching: predicate)
    
    if let event = events.first(where: { $0.title == targetTitle }) {
        event.startDate = newStartDate
        event.endDate = newStartDate.addingTimeInterval(durationMinutes * 60)
        
        do {
            try store.save(event, span: .thisEvent)
            print(" moved: \(event.title!) -> \(newStartDate)")
        } catch {
            print("Error saving: \(error)")
        }
    } else {
        print("Error: Event '\(targetTitle)' not found")
    }
    semaphore.signal()
}

semaphore.wait()
