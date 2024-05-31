//
// Globals.swift
//  

import Foundation

// MARK: - Internal Variables

/// Master graph resolution depth counter
internal var globalGraphResolutionDepth = 0

/// Internal key used for Resolver mode
internal var globalResolverKey: StaticString = "*"

#if DEBUG
/// Internal variables used for debugging
internal var globalDependencyChain: [String] = []
internal var globalDependencyChainMessages: [String] = []
internal var globalTraceFlag: Bool = false
internal var globalTraceResolutions: [String] = []
internal var globalLogger: (String) -> Void = { print($0) }
internal var globalDebugInformationMap: [FactoryKey:FactoryDebugInformation] = [:]

/// Triggers fatalError after resetting enough stuff so unit tests can continue
internal func resetAndTriggerFatalError(_ message: String, _ file: StaticString, _ line: UInt) -> Never {
    globalDependencyChain = []
    globalDependencyChainMessages = []
    globalGraphResolutionDepth = 0
    globalRecursiveLock = RecursiveLock()
    globalTraceResolutions = []
    triggerFatalError(message, file, line) // GOES BOOM
}

/// Allow unit test interception of any fatal errors that may occur running the circular dependency check
/// Variation of solution: https://stackoverflow.com/questions/32873212/unit-test-fatalerror-in-swift#
internal var triggerFatalError = Swift.fatalError
#endif
