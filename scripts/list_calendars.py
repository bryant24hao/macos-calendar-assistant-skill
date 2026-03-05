#!/usr/bin/env python3
import subprocess
import json
import sys

SWIFT_SCRIPT = r'''
import EventKit
import Foundation

struct CalendarInfo: Codable {
    let name: String
    let account: String
    let type: String
    let writable: Bool
}

struct Output: Codable {
    let calendars: [CalendarInfo]
}

let store = EKEventStore()
let calendars = store.calendars(for: .event)
var infos: [CalendarInfo] = []

for cal in calendars {
    guard let source = cal.source else { continue }
    
    var typeString = "Unknown"
    switch source.sourceType {
    case .local: typeString = "Local"
    case .exchange: typeString = "Exchange"
    case .calDAV: typeString = "CalDAV" // iCloud
    case .mobileMe: typeString = "MobileMe"
    case .subscribed: typeString = "Subscribed"
    case .birthdays: typeString = "Birthdays"
    @unknown default: typeString = "Other"
    }
    
    // Subscribed/Birthdays are usually read-only
    // But let's check allowsContentModifications
    let isWritable = cal.allowsContentModifications
    
    infos.append(CalendarInfo(name: cal.title, account: source.title, type: typeString, writable: isWritable))
}

let output = Output(calendars: infos)
let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted
if let data = try? encoder.encode(output), let jsonString = String(data: data, encoding: .utf8) {
    print(jsonString)
}
'''

def main():
    # Write swift to temp file or pipe
    # Piping is harder with swift interpreter in one go without a file sometimes, 
    # but 'swift -' works.
    try:
        p = subprocess.run(
            ["swift", "-"],
            input=SWIFT_SCRIPT,
            capture_output=True,
            text=True,
            check=True
        )
        print(p.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error: {e.stderr}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
