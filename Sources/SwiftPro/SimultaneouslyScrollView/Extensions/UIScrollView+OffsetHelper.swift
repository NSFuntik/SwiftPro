#if os(iOS) || os(tvOS) 
import UIKit

internal extension UIScrollView {
    var isAtBottom: Bool {
        contentOffset.y >= (contentSize.height - frame.size.height)
    }

    var hasContentToFillScrollView: Bool {
        contentSize.height > bounds.size.height
    }
}
#endif
