//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 16.04.2024.
//

import SwiftUI

public protocol Observable: ObservableObject {}
extension View {
    /// Places a perceptible object in the view’s environment.
    ///
    /// A backport of SwiftUI's `View.environment` that takes an observable object.
    ///
    /// - Parameter object: The object to set for this object's type in the environment, or `nil` to
    ///   clear an object of this type from the environment.
    /// - Returns: A view that has the specified object in its environment.
    @_disfavoredOverload
    public func environment<T: AnyObject & Observable>(_ object: T?) -> some View {
        self.environment(\.[\T.self], object)
    }
}

private struct PerceptibleKey<T: Observable>: EnvironmentKey {
    static var defaultValue: T? { nil }
}

extension EnvironmentValues {
    fileprivate subscript<T: Observable>(_: KeyPath<T, T>) -> T? {
        get { self[PerceptibleKey<T>.self] }
        set { self[PerceptibleKey<T>.self] = newValue }
    }

    fileprivate subscript<T: Observable>(unwrap _: KeyPath<T, T>) -> T {
        get {
            guard let object = self[\T.self] else {
                fatalError(
                    """
                    No perceptible object of type \(T.self) found. A View.environment(_:) for \(T.self) may \
                    be missing as an ancestor of this view.
                    """
                )
            }
            return object
        }
        set { self[\T.self] = newValue }
    }
}
extension Task {
    func whenAll<T>(tasks: [Task<T, Error>]) async throws -> [T] {
        try await withThrowingTaskGroup(of: [T].self, body: { group in
            for task in tasks {
                group.addTask {
                    [try await task.value]
                }
            }
            return try await group.reduce([], +)
        })
    }
}
