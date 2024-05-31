//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 17.05.2024.
//

import SwiftUI
/// This style makes the button take up the entire row, then
/// applies a shape that makes the entire view tappable.
///
/// You can apply this style with `.buttonStyle(.list)`, and
/// can apply it to an entire list, like any other style.
public struct ListButtonStyle: ButtonStyle {
    /// Create a custom style.
    ///
    /// - Parameters:
    ///   - pressedOpacity: The opacity to apply when the button is pressed, by default `0.5`.
    public init(
        pressedOpacity: Double = 0.5
    ) {
        self.pressedOpacity = pressedOpacity
    }

    /// The opacity to apply when the button is pressed.
    var pressedOpacity: Double

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? pressedOpacity : 1)
    }
}

public extension ButtonStyle where Self == ListButtonStyle {
    /// The standard list card button style.
    static var list: ListButtonStyle { .init() }

    /// A custom list card button style.
    static func list(
        pressedOpacity: Double
    ) -> Self {
        .init(pressedOpacity: pressedOpacity)
    }
}

public extension ButtonStyle where Self == RefreshButtonStyle {
    static var refresh: Self { .init() }
}

public struct RefreshButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(configuration.isPressed ? .regularMaterial : .ultraThinMaterial, in: Capsule(style: .continuous))

            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

public extension Button.StandardType {
    var id: String { rawValue }

    var image: Image? {
        guard let imageName else { return nil }
        return .system(imageName)
    }

    var imageName: String? {
        switch self {
        case .add: "plus"
        case .addFavorite: "star.circle"
        case .addToFavorites: "star.circle"
        case .cancel: "xmark"
        case .call: "phone"
        case .copy: "doc.on.doc"
        case .delete: "trash"
        case .deselect: "checkmark.circle.fill"
        case .done: "checkmark"
        case .edit: "pencil"
        case .email: "envelope"
        case .ok: "checkmark"
        case .paste: "clipboard"
        case .removeFavorite: "star.circle.fill"
        case .removeFromFavorites: "star.circle.fill"
        case .select: "checkmark.circle"
        case .share: "square.and.arrow.up"
        }
    }

    var role: ButtonRole? {
        switch self {
        case .cancel: .cancel
        case .delete: .destructive
        default: nil
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .add: "Button.Add"
        case .addFavorite: "Button.AddFavorite"
        case .addToFavorites: "Button.AddToFavorites"
        case .call: "Button.Call"
        case .cancel: "Button.Cancel"
        case .copy: "Button.Copy"
        case .deselect: "Button.Deselect"
        case .edit: "Button.Edit"
        case .email: "Button.Email"
        case .delete: "Button.Delete"
        case .done: "Button.Done"
        case .ok: "Button.OK"
        case .paste: "Button.Paste"
        case .removeFavorite: "Button.RemoveFavorite"
        case .removeFromFavorites: "Button.RemoveFromFavorites"
        case .select: "Button.Select"
        case .share: "Button.Share"
        }
    }
}

public extension Button where Label == SwiftUI.Label<Text, Image> {
    /// This initializer lets you use buttons with less code.
    init(
        _ text: LocalizedStringKey,
        _ icon: Image,
        _ bundle: Bundle = .main,
        action: @escaping () -> Void
    ) {
        self.init(action: action) {
            Label(
                title: { Text(text, bundle: bundle) },
                icon: { icon }
            )
        }
    }
}

#Preview {
    @ViewBuilder
    func buttons() -> some View {
        Section {
            ForEach(Button.StandardType.allCases) {
                Button($0) {}
            }
        }
    }

    return List {
        buttons()
        buttons().labelStyle(.titleOnly)
        buttons().labelStyle(.iconOnly)
    }.overlay(alignment: .top, content: { Button("Refresh Button", .init(sf: .arrowClockwise), action: { }).padding(33).buttonStyle(.refresh) })
    .toolbar {
        ToolbarItemGroup {
            buttons()
        }
    }
}
