//
//  FloatingTextField.swift
//
//
//  Created by Dmitry Mikhaylov on 26.04.2024.
//

import SwiftUI

public struct FloatingTextField: View {
    let placeholderText: String
    @State private var text: String = ""

    let animation: Animation = .spring(response: 0.1, dampingFraction: 0.6)

    @State private var placeholderOffset: CGFloat
    @State private var scaleEffectValue: CGFloat

    private var onTextAction: ((_ oldValue: String, _ newValue: String) -> Void)?

    public init(
        placeholderText: String,
        placeholderOffset offset: CGFloat = 0,
        scaleEffectValue scale: CGFloat = 1,
        onTextAction: ((_: String, _: String) -> Void)? = nil
    ) {
        self.placeholderText = placeholderText
        self._placeholderOffset = State(initialValue: offset)
        self._scaleEffectValue = State(initialValue: scale)
        self.onTextAction = onTextAction
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            Text(placeholderText)
                .foregroundStyle($text.wrappedValue.isEmpty ? Color(.secondaryLabel) : Color(.placeholderText))
                .font($text.wrappedValue.isEmpty ? .headline : .caption)
                .offset(y: placeholderOffset)
                .scaleEffect(scaleEffectValue, anchor: .leading)

            TextField("", text: $text)
                .font(.headline)
                .foregroundStyle(Color(.label))
        }
        .padding()
        .padding(.vertical, 5)
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color(.separator), lineWidth: 2)
        )
        .onChange(of: text) { newValue in
            withAnimation(animation) {
                placeholderOffset = $text.wrappedValue.isEmpty ? 0 : -25
                scaleEffectValue = $text.wrappedValue.isEmpty ? 1 : 0.75
            }

            onTextAction?(text, newValue)
        }
    }
}

public extension FloatingTextField {
    func onTextChange(_ onTextAction: ((_ oldValue: String, _ newValue: String) -> Void)?) -> Self {
        var view = self
        view.onTextAction = onTextAction
        return view
    }
}
