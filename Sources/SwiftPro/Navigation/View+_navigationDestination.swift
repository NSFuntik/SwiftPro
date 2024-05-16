import SwiftUI

public struct NavigationLinkModifier<Destination: View>: ViewModifier {
    @Binding var isActiveBinding: Bool
    var destination: Destination
    @Environment(\.isWithinNavigationStack) var isWithinNavigationStack

    public func body(content: Content) -> some View {
        if #available(iOS 16.0, *, macOS 13.0, *, watchOS 9.0, *, tvOS 16.0, *), isWithinNavigationStack {
            AnyView(
                content
                    .navigationDestination(isPresented: $isActiveBinding, destination: { destination })
            )
        } else {
            AnyView(
                content
                    .background(
                        NavigationLink(destination: destination, isActive: $isActiveBinding, label: EmptyView.init)
                            .hidden()
                    )
            )
        }
    }
}

public extension View {
    func _navigationDestination<Destination: View>(isActive: Binding<Bool>, destination: Destination) -> some View {
        return modifier(NavigationLinkModifier(isActiveBinding: isActive, destination: destination))
    }
}
