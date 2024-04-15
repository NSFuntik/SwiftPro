//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 27.02.2024.
//

import Foundation

public extension ISO8601DateFormatter {
    static var full: ISO8601DateFormatter {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withFullDate]
        isoDateFormatter.timeZone = .autoupdatingCurrent
        return isoDateFormatter
    }
}

public extension DateFormatter {
     convenience init(dateFormat: String = ISO8601DateFormatter.string(from: .now, timeZone: .autoupdatingCurrent)) {
        self.init()
        locale = Locale.current
        self.dateFormat = dateFormat
    }

    static let timeFormatter = {
        let formatter = DateFormatter()

        formatter.dateStyle = .none
        formatter.timeStyle = .short

        return formatter
    }()

    static let relativeDateFormatter = {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .none
        relativeDateFormatter.dateStyle = .full
        relativeDateFormatter.locale = Locale.autoupdatingCurrent
        relativeDateFormatter.doesRelativeDateFormatting = true

        return relativeDateFormatter
    }()

    static func timeString(_ seconds: Int) -> String {
        let hour = Int(seconds) / 3600
        let minute = Int(seconds) / 60 % 60
        let second = Int(seconds) % 60

        if hour > 0 {
            return String(format: "%02i:%02i:%02i", hour, minute, second)
        }
        return String(format: "%02i:%02i", minute, second)
    }
}

public extension Date {
    init?(string dateString: String?, format: String? = nil) throws {
        guard let dateString, let format else {
            throw CocoaError(.coderValueNotFound)
        }
        if let date = DateFormatter(dateFormat: format).date(from: dateString) {
            self = date
        } else if let date = DateFormatter(dateFormat: "yyyy-MM-ddTHH:mm:ssZ").date(from: dateString) {
            self = date
        } else {
            do {
                let isoDate = try ISO8601FormatStyle().parse(dateString)
                self = isoDate
            } catch {
                throw error
            }
        }
    }

    var string: String {
        let string = ISO8601DateFormatter.full.string(from: self)
        debugPrint(string)
        return string
    }
}

public extension Date {
    func fullDistance(from date: Date, resultIn component: Calendar.Component, calendar: Calendar = .current) -> Int? {
        calendar.dateComponents([component], from: self, to: date).value(for: component)
    }

    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let days1 = calendar.component(component, from: self)
        let days2 = calendar.component(component, from: date)
        return days1 - days2
    }

    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        distance(from: date, only: component) == 0
    }
}

public extension Date {
    /// Timestamp in milliseconds
    var timestamp: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }

    static var currentTimeStamp: Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
