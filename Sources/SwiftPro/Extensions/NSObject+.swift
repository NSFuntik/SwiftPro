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
            if let id = UserDefaults.standard.string(forKey: "deviceID") {
                debugPrint("UserDefaults Device ID: \(id)")
                return id
            } else {
                let id = UUID().uuidString
                UserDefaults.standard.set(id, forKey: "deviceID")
                debugPrint("NEW UserDefaults Device ID: \(id)")
                return id
            }
        }
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
    
    class func getTopVC(base: UIViewController?
                        = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let presented = base?.presentedViewController {
            return getTopVC(base: presented)
        }
        return base
    }
}

public extension UIApplication {
    func endEditing(action: () -> Void = { }) {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        action()
    }
}
