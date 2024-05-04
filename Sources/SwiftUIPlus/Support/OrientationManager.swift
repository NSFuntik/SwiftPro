//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 27.03.2024.
//

import Combine

import SwiftUI

// @propertyWrapper struct Orientation: DynamicProperty {
//    @Perception.Bindable var manager = OrientationManager.shared
//
//    var wrappedValue: UIDeviceOrientation {
//        manager.type
//    }
// }
public extension EnvironmentValues {
    var orientation: OrientationManager {
        get { self[OrientationKey.self] }
        set { self[OrientationKey.self] = newValue }
    }
}

public struct OrientationKey: EnvironmentKey {
    public static var defaultValue: OrientationManager = OrientationManager.shared
}

public extension UIDeviceOrientation {
    var notchSide: Edge.Set {
        switch self {
        case .landscapeLeft:
            return .leading
        case .landscapeRight:
            return .trailing
        default:
            return .top
        }
    }
}

public
final class OrientationManager: Observable {
    public var type: UIDeviceOrientation = .unknown
    
    private var cancellables: Set<AnyCancellable> = []
    public static let shared = OrientationManager()
    private init() {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let sceneDelegate = scene as? UIWindowScene else { return }
        
        let orientation = sceneDelegate.interfaceOrientation
        
        switch orientation {
        case .portrait: type = .portrait
        case .portraitUpsideDown: type = .portraitUpsideDown
        case .landscapeLeft: type = .landscapeLeft
        case .landscapeRight: type = .landscapeRight
            
        default: type = .unknown
        }
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { _ in
                Task { @MainActor in
                    
                    self.type = UIDevice.current.orientation
                }
            }
            .store(in: &cancellables)
    }
}
