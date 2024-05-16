import Foundation
import SwiftUI

/// An object that never publishes changes, but allows appending to an NBNavigationStack's path.
public class PathAppender: ObservableObject {
  var append: ((AnyHashable) -> Void)?
}
