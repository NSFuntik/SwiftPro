import SwiftUI

public extension View {
    @available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
    /// Sets the policy for whether to use SwiftUI's built-in `NavigationStack` when available (i.e. when the SwiftUI
    /// version includes it). The default behaviour is to never use `NavigationStack` - instead `NavigationView`
    /// will be used on all versions, even when the API is available.
    /// - Parameter policy: The policy to use
    /// - Returns: A view with the policy set for all child views via a private environment value.
    func nbUseNavigationStack(_ policy: UseNavigationStackPolicy) -> some View {
        environment(\.useNavigationStack, policy)
    }
}
