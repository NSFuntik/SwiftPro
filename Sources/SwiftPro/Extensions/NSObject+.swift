//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 27.02.2024.
//
import AdSupport
import AppTrackingTransparency
import UIKit

public func runOnMainActor(
    _ action: @escaping @MainActor () -> Void
) {
    Task { @MainActor in
        action()
    }
}

public func asyncOnMainActor(
    _ action: @escaping @Sendable @MainActor  () async -> Void
) {
    Task { @MainActor in
       await action()
    }
}

public func runOnMainQueue(
    _ action: @escaping () -> Void
) {
    DispatchQueue.main.async {
        action()
    }
}

#if canImport(UIKit)
import UIKit

#elseif canImport(AppKit)
import AppKit
public typealias Image = NSImage
#endif

public func unwrapOrThrow<T>(_ optional: T?, _ error: Error) throws -> T {
    if let value = optional {
        return value
    } else {
        throw error
    }
}

public extension Bool {
    func trueOrThrow(_ error: Error) throws {
        if !self {
            throw error
        }
    }
}

public extension Optional {
    
    /// Whether or not the value is `nil`.
    var isNil: Bool { self == nil }
    
    /// Whether or not the value is set and not `nil`.
    var isSet: Bool { !isNil }
}

/// Use to wrap primitive Codable
public struct TypeWrapper<T: Codable>: Codable {
    enum CodingKeys: String, CodingKey {
        case object
    }
    
    public let object: T
    
    public init(object: T) {
        self.object = object
    }
}

public  class Utils {
    public static func image(data: Data) -> UIImage? {
#if canImport(UIKit)
        return UIImage(data: data)
#elseif canImport(AppKit)
        return NSImage(data: data)
#else
        return nil
#endif
    }
    
    public static func data(image: UIImage) -> Data? {
#if canImport(UIKit)
        return image.jpegData(compressionQuality: 0.9)
#elseif canImport(AppKit)
        return image.tiffRepresentation
#else
        return nil
#endif
    }
}

public struct File {
    public let name: String
    public let url: URL
    public let modificationDate: Date?
    public let size: UInt64?
    
   public init(
        name: String,
        url: URL,
        modificationDate: Date?,
        size: UInt64?
    ) {
        self.name = name
        self.url = url
        self.modificationDate = modificationDate
        self.size = size
    }
}

public extension File {
    init?(url: URL) {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) else {
            return nil
        }
        self.name = url.lastPathComponent
        self.url = url
        self.modificationDate = attributes[.modificationDate] as? Date
        self.size = attributes[.size] as? UInt64
    }
}

public extension UIView {
    func closestVC() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
}


public extension CGFloat {
    @inline(__always)
    static var screenWidth: CGFloat {
        return UIScreen.mainScreen.bounds.width
    }
    
    @inline(__always)
    static var screenHeight: CGFloat {
        return UIScreen.mainScreen.bounds.height
    }
}

public extension UIApplication {
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
}

public extension UIApplication {
    func endEditing(action: () -> Void = { }) {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        action()
    }
}
