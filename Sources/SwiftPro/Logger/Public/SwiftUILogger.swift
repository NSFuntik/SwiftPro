
import os.log
import SwiftUI
///

open class SwiftUILogger: ObservableObject {
    ///
    public enum Level: Int {
        case success, info, warning, error, fatal, debug, trace

        public var description: String {
            switch self {
            case .success: return "Success"
            case .info: return "Info"
            case .warning: return "Warning"
            case .error: return "Error"
            case .fatal: return "Fatal"
            case .debug: return "Debug"
            case .trace: return "Trace"
            }
        }

        public var color: Color {
            switch self {
            case .success: return .green
            case .info: return .mint
            case .warning: return .yellow
            case .error: return .red
            case .fatal: return .red
            case .debug: return .purple
            case .trace: return .clear
            }
        }

        public var emoji: Image {
            let systemName: String = switch self {
            case .success: "party.popper.fill"
            case .info: "stethoscope"
            case .warning: "drop.triangle.fill"
            case .error: "delete.right.fill"
            case .fatal: "light.beacon.max.fill"
            case .debug: "apple.terminal.on.rectangle"
            case .trace: "calendar.day.timeline.left"
            }
            return Image(systemName: systemName).symbolRenderingMode(.multicolor)
        }

        public var symbol: String {
            let systemName: String = switch self {
            case .success: "􁓵"
            case .info: "􀝾"
            case .warning: "􀈀"
            case .error: "􀆗"
            case .fatal: "􁒱"
            case .debug: "􁹛"
            case .trace: "􀻤"
            }
            return systemName
        }
    }

    ///
    public struct Event: Identifiable {
        public struct Metadata {
            public let file: StaticString
            public let line: Int
            public let tags: [any LogTagging]

            public init(
                file: StaticString,
                line: Int,
                tags: [any LogTagging]
            ) {
                self.file = file
                self.line = line
                self.tags = tags
            }
        }

        static let dateFormatter: DateFormatter = {
            var formatter = DateFormatter()

            formatter.timeStyle = .none
            formatter.dateStyle = .short

            return formatter
        }()

        static let timeFormatter: DateFormatter = {
            var formatter = DateFormatter()

            formatter.timeStyle = .long
            formatter.dateStyle = .none

            return formatter
        }()

        ///
        public let id: UUID

        ///
        public let dateCreated: Date

        ///
        public let level: Level

        ///
        public let message: String

        ///
        public let error: Error?

        ///
        public let metadata: Metadata

        ///
        public init(
            level: Level,
            message: String,
            error: Error? = nil,
            tags: [any LogTagging] = [],
            _ file: StaticString = #fileID,
            _ line: Int = #line
        ) {
            self.id = UUID()
            self.dateCreated = Date()
            self.level = level
            self.message = message
            self.error = error
            self.metadata = .init(
                file: file,
                line: line,
                tags: tags
            )
        }
    }

    ///
    public static var `default`: SwiftUILogger = SwiftUILogger()

    ///
    @usableFromInline var lock: NSLock

    ///
    public let name: String?

    ///
    @Published var filteredTags: Set<String>

    ///
    @Published public var logs: [Event]
    public var displayedLogs: [Event] {
        return filteredTags.isEmpty
            ? logs
            : logs.filter {
                $0.metadata.tags.first(
                    where: { filteredTags.contains($0.value) }
                ) != nil
            }
    }

    ///
    open var blob: String {
        lock.lock()
        defer { lock.unlock() }

        return displayedLogs
            .map { event -> String in
                let date = Event.dateFormatter.string(from: event.dateCreated)
                let time = Event.timeFormatter.string(from: event.dateCreated)
                let emoji = event.level.emoji
                let eventMessage = "\(date) \(time) \(emoji): \(event.message) (File: \(event.metadata.file)@\(event.metadata.line))"

                guard let error = event.error else {
                    return eventMessage
                }

                return eventMessage + "(Error: \(error.localizedDescription))"
            }
            .joined(separator: "\n")
    }

    ///
    public init(
        name: String? = nil,
        logs: [Event] = []
    ) {
        self.lock = NSLock()
        self.name = name
        self.logs = logs

        self.filteredTags = []
    }

    ///

    @inlinable open func log(
        _ level: Level,
        _ message: String,
        _ error: Error? = nil,
        _ tags: [any LogTagging] = [],
        _ file: StaticString = #fileID,
        _ line: Int = #line
    ) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async {
                self.log(level, message, error, tags, file, line)
            }
        }

        lock.lock()
        defer {
            #if DEBUG
                let osLog = Logger(subsystem: Bundle.debugDescription(), category: file.description.appending(" \(line)"))
                switch level {
                case .debug, .success: osLog.debug("\(level.symbol) \(message)")
                case .trace: osLog.trace("\(level.symbol) \(message)")
                case .info: osLog.info("\(level.symbol) \(message)")
                case .warning: osLog.warning("\(level.symbol) \(message)")
                case .error: osLog.error("\(level.symbol) \(message)")
                case .fatal: osLog.fault("\(level.symbol) \(message)")
                }
            #endif
            lock.unlock()
        }
        DispatchQueue.main.async {
            self.logs.append(
                Event(
                    level: level,
                    message: message,
                    error: error,
                    tags: tags,
                    file,
                    line
                )
            )
        }
    }

    ///
    @inlinable open func trace(
        _ message: String,
        _ tags: [any LogTagging] = [],
        _ file: StaticString = #fileID,
        _ line: Int = #line
    ) {
        log(
            .trace,
            message,
            nil,
            tags,
            file,
            line
        )
    }

    ///
    @inlinable open func success(
        _ message: String,
        _ tags: [any LogTagging] = [],
        _ file: StaticString = #fileID,
        _ line: Int = #line
    ) {
        log(
            .success,
            message,
            nil,
            tags,
            file,
            line
        )
    }

    @inlinable open func debug(
        _ message: String,
        _ tags: [any LogTagging] = [],
        _ file: StaticString = #fileID,
        _ line: Int = #line
    ) {
        log(
            .info,
            message,
            nil,
            tags,
            file,
            line
        )
    }

    ///
    @inlinable open func info(
        _ message: String,
        _ tags: [any LogTagging] = [],
        _ file: StaticString = #fileID,
        _ line: Int = #line
    ) {
        log(
            .info,
            message,
            nil,
            tags,
            file,
            line
        )
    }

    ///
    @inlinable open func warning(
        _ message: String,
        _ tags: [any LogTagging] = [],
        _ file: StaticString = #fileID,
        _ line: Int = #line
    ) {
        log(
            .warning,
            message,
            nil,
            tags,
            file,
            line
        )
    }

    @inlinable open func fault(
        _ message: String,
        _ tags: [any LogTagging] = [],
        _ file: StaticString = #fileID,
        _ line: Int = #line
    ) {
        log(
            .warning,
            message,
            nil,
            tags,
            file,
            line
        )
    }

    ///
    @inlinable open func error(
        _ message: String,
        error: Error? = nil,
        _ tags: [any LogTagging] = [],
        _ file: StaticString = #fileID,
        _ line: Int = #line
    ) {
        log(
            .error,
            message,
            error,
            tags,
            file,
            line
        )
    }

    ///
    @inlinable open func fatal(
        _ message: String,
        error: Error?,
        _ tags: [any LogTagging] = [],
        _ file: StaticString = #fileID,
        _ line: Int = #line
    ) {
        log(
            .fatal,
            message,
            error,
            tags,
            file,
            line
        )
    }
}
