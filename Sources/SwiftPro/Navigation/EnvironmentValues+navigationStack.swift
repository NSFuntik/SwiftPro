import SwiftUI

public struct UseNavigationStackPolicyKey: EnvironmentKey {
    public static let defaultValue = UseNavigationStackPolicy.whenAvailable
}

public struct IsWithinNavigationStackKey: EnvironmentKey {
    public static let defaultValue = false
}

public extension EnvironmentValues {
  var useNavigationStack: UseNavigationStackPolicy {
    get { self[UseNavigationStackPolicyKey.self] }
    set { self[UseNavigationStackPolicyKey.self] = newValue }
  }

  var isWithinNavigationStack: Bool {
    get { self[IsWithinNavigationStackKey.self] }
    set { self[IsWithinNavigationStackKey.self] = newValue }
  }
}
