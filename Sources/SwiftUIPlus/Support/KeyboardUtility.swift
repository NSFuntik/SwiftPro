//
//  File.swift
//  
//
//  Created by Dmitry Mikhaylov on 10.04.2024.
//

import SwiftUI

public extension View {
    dynamic func dismissKeyboardOnTappingOutside() -> some View {
        return ModifiedContent(content: self, modifier: DismissKeyboardOnTappingOutside())
    }
}

@frozen public struct DismissKeyboardOnTappingOutside: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .onTapGesture {
#if os(iOS)
                UIApplication.shared.endEditing()
#endif
            }
    }
}
