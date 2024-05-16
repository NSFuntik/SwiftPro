//
//  File.swift
//  
//
//  Created by Dmitry Mikhaylov on 16.05.2024.
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
