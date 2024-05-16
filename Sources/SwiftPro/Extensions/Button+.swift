//
//  File.swift
//  
//
//  Created by Dmitry Mikhaylov on 17.05.2024.
//

import SwiftUI
public extension ButtonStyle where Self == RefreshButtonStyle {
    static var refresh: Self { .init() }
}

public struct RefreshButtonStyle: ButtonStyle {
    public  func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background {
                Capsule(style: .continuous)
                    .foregroundColor(.primary.opacity(configuration.isPressed ? 0.2 : 0.1))
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

public extension Button.StandardType {
    var id: String { rawValue }
    
    var image: Image? {
        guard let imageName else { return nil }
        return  .system(imageName)
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
    }
    .toolbar {
        ToolbarItemGroup {
            buttons()
        }
    }
}
