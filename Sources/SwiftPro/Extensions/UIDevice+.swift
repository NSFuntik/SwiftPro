//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 17.05.2024.
//

import UIKit

public extension UIScreen {
    @nonobjc
    static var mainScreen: UIScreen { .main }

    @nonobjc
    static var orientation: UIDeviceOrientation {
        let point = UIScreen.mainScreen.coordinateSpace.convert(CGPoint.zero, to: UIScreen.mainScreen.fixedCoordinateSpace)
        if point == CGPoint.zero {
            return .portrait
        } else if point.x != 0 && point.y != 0 {
            return .portraitUpsideDown
        } else if point.x == 0 && point.y != 0 {
            return .landscapeRight // .landscapeLeft
        } else if point.x != 0 && point.y == 0 {
            return .landscapeLeft // .landscapeRight
        } else {
            return .unknown
        }
    }
}

/**
 This protocol can be implemented by types that can check if
 the code is running in a SwiftUI preview.

 The protocol is implemented by `ProcessInfo`.
 */
public protocol SwiftPreviewInspector {
    /// Whether or not the code runs in a SwiftUI preview.
    var isSwiftUIPreview: Bool { get }
}

public extension SwiftPreviewInspector {
    /// Whether or not the code runs in a SwiftUI preview.
    var isSwiftUIPreview: Bool {
        ProcessInfo.isSwiftUIPreview
    }
}

extension ProcessInfo: SwiftPreviewInspector {}

public extension ProcessInfo {
    /// Whether or not the code runs in a SwiftUI preview.
    var isSwiftUIPreview: Bool {
        environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    /// Whether or not the code runs in a SwiftUI preview.
    static var isSwiftUIPreview: Bool {
        processInfo.isSwiftUIPreview
    }
}

public extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    static var deviceId: String {
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            debugPrint("IdentifierForVendor Device ID: \(uuid)")
            return uuid
        } else {
            debugPrint("Unable to retrieve device ID.")
            debugPrint("Requesting tracking authorization.")
            if let id = suite.string(forKey: "deviceID") {
                debugPrint("UserDefaults Device ID: \(id)")
                return id
            } else {
                let id = UUID().uuidString
                suite.set(id, forKey: "deviceID")
                debugPrint("NEW UserDefaults Device ID: \(id)")
                return id
            }
        }
    }
}

/// This class can generate a unique device identifier, that
/// is persisted even when uninstalling the app.
open class DeviceIdentifier {
    /// Create a device identifier.
    ///
    /// - Parameters:
    ///   - keychainService: The service to use for keychain support, by default `.shared`.
    ///   - keychainAccessibility: The keychain accessibility to use, by default `nil`.
    ///   - store: The user defaults to persist ID in, by default `.standard`.
    public init(
        keychainService: KeychainService,
        store: UserDefaults = .standard
    ) {
        self.keychainService = keychainService
        self.store = store
    }

    private let keychainService: KeychainService
    private let store: UserDefaults

    /// Get a unique device identifier from any store.
    ///
    /// If no device identifier exists, this identifier will
    /// generate a new identifier and persist it in both the
    /// keychain and in user defaults.
    open func getDeviceIdentifier() -> String {
        let keychainId = keychainService.string(for: key)
        let storeId = store.string(forKey: key)
        let id = keychainId ?? storeId ?? UUID().uuidString
        if keychainId == nil || storeId == nil { setDeviceIdentifier(id) }
        return id
    }

    /// Remove the unique device identifier from all stores.
    open func resetDeviceIdentifier() {
        store.removeObject(forKey: key)
        keychainService.removeObject(for: key)
    }

    /// Write a unique device identifier to all stores.
    open func setDeviceIdentifier(_ id: String) {
        store.set(id, forKey: key)
        keychainService.set(id, for: key)
    }
}

extension DeviceIdentifier {
    var key: String { "com.nsswift.deviceidentifier" }
}

public extension Bundle {
    
    /// Get the bundle build number string, e.g. `123`.
    var buildNumber: String {
        let key = String(kCFBundleVersionKey)
        let version = infoDictionary?[key] as? String
        return version ?? ""
    }
    
    /// Get the bundle display name, if any.
    var displayName: String {
        infoDictionary?["CFBundleDisplayName"] as? String ?? "-"
    }
    
    /// Get the bundle version number string, e.g. `1.2.3`.
    var versionNumber: String {
        let key = "CFBundleShortVersionString"
        let version = infoDictionary?[key] as? String
        return version ?? "0.0.0"
    }
}
