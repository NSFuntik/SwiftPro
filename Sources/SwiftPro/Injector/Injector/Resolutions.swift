//
// Resolutions.swift
//


import Foundation

/// Global function to resolve a keypath on Container.shared into the requested type
///
/// ```swift
/// @State var model: ContentViewModel = resolve(\.contentViewModel)
/// ```
public func resolve<T>(_ keyPath: KeyPath<Container, Factory<T>>) -> T {
    Container.shared[keyPath: keyPath]()
}

/// Global function to resolve a keypath on the specified shared container into the requested type
///
/// ```swift
/// @State var model: ContentViewModel = resolve(\MyContainer.contentViewModel)
/// ```
public func resolve<C:SharedContainer, T>(_ keyPath: KeyPath<C, Factory<T>>) -> T {
    C.shared[keyPath: keyPath]()
}
