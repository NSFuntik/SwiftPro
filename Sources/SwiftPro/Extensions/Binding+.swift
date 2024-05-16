//
//  File.swift
//  
//
//  Created by Dmitry Mikhaylov on 17.05.2024.
//

import SwiftUI
public extension Button {
    /// Create a new ``StandardType``-based button.
    init(
        _ type: StandardType,
        _ title: LocalizedStringKey? = nil,
        _ icon: Image? = nil,
        bundle: Bundle? = nil,
        action: @escaping () -> Void
    ) where Label == SwiftUI.Label<Text, Image?> {
        self.init(role: type.role, action: action) {
            Label(
                title: { Text(title ?? type.title, bundle: title == nil ? .module : bundle) },
                icon: { icon ?? type.image }
            )
        }
    }
    
    /// This enum defines standard button types and provides
    /// standard localized texts and icons.
    enum StandardType: String, CaseIterable, Identifiable {
        case add, addFavorite, addToFavorites,
             cancel, call, copy,
             delete, deselect, done,
             edit, email,
             ok,
             paste,
             removeFavorite, removeFromFavorites,
             select, share
    }
}
public extension Binding {
    @inlinable
    func unwrapped<T>(_ defaultValue: T) -> Binding<T> where Value == Optional<T> {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

/**
 This type makes it possible to use optional bindings with a
 range of native SwiftUI controls.
 
 To pass in optional bindings to any non-optional parameters,
 just define a fallback value:
 
 ```swift
 @State
 var myValue: Double?
 
 func doSomething(with binding: Binding<Double>) { ... }
 
 doSomething(with: $myValue ?? 0)
 ```
 */
public func OptionalBinding<T>(_ binding: Binding<T?>, _ defaultValue: T) -> Binding<T> {
    Binding<T>(get: {
        binding.wrappedValue ?? defaultValue
    }, set: {
        binding.wrappedValue = $0
    })
}

public func ?? <T>(left: Binding<T?>, right: T) -> Binding<T> {
    OptionalBinding(left, right)
}
