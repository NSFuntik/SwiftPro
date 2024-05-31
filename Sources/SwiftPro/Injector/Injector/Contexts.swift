//
// Contexts.swift
//

import Foundation

/// Context types available for special purpose factory registrations.
public enum FactoryContextType: Equatable {
    /// Context used when application is launched with a particular argument.
    case arg(String)
    /// Context used when application is launched with a particular argument or arguments.
    case args([String])
    /// Context used when application is running in Xcode Preview mode.
    case preview
    /// Context used when application is running in Xcode Unit Test mode.
    case test
    /// Context used when application is running in Xcode DEBUG mode.
    case debug
    /// Context used when application is running within an Xcode simulator.
    case simulator
    /// Context used when application is running on an actual device.
    case device
}

public struct FactoryContext {
    /// Proxy for application arguments.
    public var arguments: [String] = ProcessInfo.processInfo.arguments
    /// Runtime arguments
    public var runtimeArguments: [String:String] = [:]
    /// Proxy check for application running in preview mode.
    public var isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    /// Proxy check for application running in test mode.
    public var isTest: Bool = NSClassFromString("XCTest") != nil
    /// Proxy check for application running in simulator.
    public var isSimulator: Bool = ProcessInfo.processInfo.environment["SIMULATOR_UDID"] != nil
    #if DEBUG
    /// Proxy checks for application running in DEBUG mode.
    public var isDebug: Bool = true
    #else
    /// Proxy check for application running in DEBUG mode.
    public var isDebug: Bool = false
    #endif
}

extension FactoryContext {
    /// Global current context.
    public static var current = FactoryContext()
}

extension FactoryContext {
    /// Add argument to global context.
    public static func setArg(_ arg: String, forKey key: String) {
        FactoryContext.current.runtimeArguments[key] = arg
    }
    /// Add argument to global context.
    public static func removeArg(forKey key: String) {
        FactoryContext.current.runtimeArguments.removeValue(forKey: key)
    }
}

