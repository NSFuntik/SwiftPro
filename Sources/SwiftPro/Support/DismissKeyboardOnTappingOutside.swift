//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 16.05.2024.
//

import SwiftUI

public extension View {
    dynamic func dismissKeyboardGestures() -> some View {
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
            .gesture(swipeGesture)
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onChanged(endEditing)
    }

    private func endEditing(_ gesture: DragGesture.Value) {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap({ $0 })
            .first?.windows
            .filter { $0.isKeyWindow }
            .first?.endEditing(true)
    }
}

#if DEBUG
struct DismissKeyboardOnTappingOutside_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            FloatingTextField(placeholderText: "Preveiw", placeholderOffset: .nan, scaleEffectValue: .zero) {_,_ in
                
            }
            Spacer()
        }.dismissKeyboardGestures()
    }
}
#endif
