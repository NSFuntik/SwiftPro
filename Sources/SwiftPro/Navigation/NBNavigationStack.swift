import Foundation
import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
/// A replacement for SwiftUI's `NavigationStack` that's available on older OS versions.
public struct NBNavigationStack<MockView: View, Root: View, Data: Hashable>: View {
    @Binding var externalTypedPath: [Data]
    @State var internalTypedPath: [Data] = []
    @StateObject var path: NavigationPathHolder
    @StateObject var pathAppender = PathAppender()
    @StateObject var destinationBuilder: DestinationBuilderHolder
    @Environment(\.useNavigationStack) var useNavigationStack
    var root: Root
    var useInternalTypedPath: Bool

    var isUsingNavigationView: Bool {
        if #available(iOS 16.0, *, macOS 13.0, *, watchOS 9.0, *, tvOS 16.0, *), useNavigationStack == .whenAvailable {
            return false
        } else {
            return true
        }
    }

    public var content: some View {
        pathAppender.append = { [weak path] newElement in
            path?.path.append(newElement)
        }
        if #available(iOS 16.0, *, macOS 13.0, *, watchOS 9.0, *, tvOS 16.0, *), useNavigationStack == .whenAvailable {
            return AnyView(
                NavigationStack(path: $path.path) {
                    root
                        .navigationDestination(for: AnyHashable.self, destination: { destinationBuilder.build($0) })
                        .navigationDestination(for: LocalDestinationID.self, destination: { destinationBuilder.build($0) })
                }
                .environment(\.isWithinNavigationStack, true)
            )
        }
        return AnyView(
            NavigationView {
                Router(rootView: root, screens: $path.path)
            }
            .navigationViewStyle(supportedNavigationViewStyle)
            .environment(\.isWithinNavigationStack, false)
        )
    }

    public var body: some View {
        content
            .environmentObject(path)
            .environmentObject(pathAppender)
            .environmentObject(destinationBuilder)
            .environmentObject(Navigator(useInternalTypedPath ? $internalTypedPath : $externalTypedPath))
            .onFirstAppear {
                guard isUsingNavigationView else {
                    // Path should already be correct thanks to initialiser.
                    return
                }
                // For NavigationView, only initialising with one pushed screen is supported.
                // Any others will be pushed one after another with delays.
                path.path = Array(path.path.prefix(1))
                path.withDelaysIfUnsupported(\.path) {
                    $0 = externalTypedPath
                }
            }
            .onChange(of: externalTypedPath) { externalTypedPath in
                guard isUsingNavigationView else {
                    path.path = externalTypedPath
                    return
                }
                path.withDelaysIfUnsupported(\.path) {
                    $0 = externalTypedPath
                }
            }
            .onChange(of: internalTypedPath) { internalTypedPath in
                guard isUsingNavigationView else {
                    path.path = internalTypedPath
                    return
                }
                path.withDelaysIfUnsupported(\.path) {
                    $0 = internalTypedPath
                }
            }
            .onChange(of: path.path) { path in
                if useInternalTypedPath {
                    guard path != internalTypedPath.map({ $0 }) else { return }
                    internalTypedPath = path.compactMap { anyHashable in
                        if let data = anyHashable.base as? Data {
                            return data
                        } else if anyHashable.base is LocalDestinationID {
                            return nil
                        }
                        fatalError("Cannot add \(type(of: anyHashable.base)) to stack of \(Data.self)")
                    }
                } else {
                    guard path != externalTypedPath.map({ $0 }) else { return }
                    externalTypedPath = path.compactMap { anyHashable in
                        if let data = anyHashable.base as? Data {
                            return data
                        } else if anyHashable.base is LocalDestinationID {
                            return nil
                        }
                        fatalError("Cannot add \(type(of: anyHashable.base)) to stack of \(Data.self)")
                    }
                }
            }
    }

    public init(path: Binding<[Data]>?,
                emptyView: MockView,
                @ViewBuilder root: () -> Root) {
        _externalTypedPath = path ?? .constant([])
        self.root = root()
        _path = StateObject(wrappedValue: NavigationPathHolder(path: path?.wrappedValue ?? []))
        useInternalTypedPath = path == nil
        _destinationBuilder = .init(wrappedValue: .init(mockEmptyView: { emptyView }))
    }
}

extension NBNavigationStack where Data == AnyHashable {
    public init(
        @ViewBuilder emptyView: () -> MockView,
        @ViewBuilder root: () -> Root) {
        self.init(path: nil, emptyView: emptyView(), root: root)
    }
}

extension NBNavigationStack where Data == AnyHashable {
    public init(
        path: Binding<NBNavigationPath>,
        @ViewBuilder emptyView: () -> MockView,
        @ViewBuilder root: () -> Root) {
        let path = Binding(
            get: { path.wrappedValue.elements },
            set: { path.wrappedValue.elements = $0 }
        )
        self.init(path: path, emptyView: emptyView(), root: root)
    }
}

var supportedNavigationViewStyle: some NavigationViewStyle {
    #if os(macOS)
        .automatic
    #else
        .stack
    #endif
}
