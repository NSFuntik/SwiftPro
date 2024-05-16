//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 02.05.2024.
//

import Photos
import SFSymbolEnum
import SwiftUI

let cameraUnavailable =
    ContentUnavailableView(
        "Camera not avaible",
        message: "Camera not avaible. Please go to Settings > \(String(describing: Bundle.main.infoDictionary?["CFBundleName"])) > Camera",
        image: SFSymbol.questionmarkVideo.image,
        action: {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }
            }
        }
    )

#Preview(body: {
    cameraUnavailable
})
// @available(iOS, introduced: 14.0, deprecated: 16.0, renamed: "ContentUnavailableView")
public struct ContentUnavailableView<Content>: View where Content: View {
    let title: String
    let message: String
    let image: Image
    var content: (() -> Content)?
    var actionTitle: String = "Retry"
    let action: (() -> Void)?
    @Environment(\.refresh) var refresh
    @Environment(\.dismiss) var dismiss

    public init(
        _ title: String,
        message: String,
        image: Image,
        actionTitle: String = "Retry",
        action: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) {
        self.title = title
        self.message = message
        self.image = image
        self.content = content
        self.actionTitle = actionTitle
        self.action = action
    }

    public init(
        _ title: String,
        image: Image,
        actionTitle: String = "Retry",
        action: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) {
        self.title = title
        self.message = ""
        self.image = image
        self.actionTitle = actionTitle
        self.content = content
        self.action = action
    }

    public init(
        _ title: String,
        symbol: String,
        actionTitle: String = "Retry",
        action: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) {
        self.title = title
        self.message = ""
        self.image = Image(systemName: symbol)
        self.actionTitle = actionTitle
        self.content = content
        self.action = action
    }

    public init(
        _ title: String,
        symbol: SFSymbol,
        description: String,
        actionTitle: String = "Retry",
        action: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) {
        self.title = title
        self.message = description
        self.image = symbol.image
        self.content = content
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 16) {
            image
                .font(.largeTitle)
                .imageScale(.large)
            Text(title)
                .font(.title.monospaced().bold()).foregroundStyle(.primary)
            Text(message)
                .font(.subheadline.bold().monospaced())
                .multilineTextAlignment(.center).foregroundStyle(.secondary)
                .highlightEffect()
            content?()
            if let _ = action {
                AsyncButton(action: action ?? { await refresh?() ?? dismiss() }, label: {
                    Label(.init(actionTitle), symbol: .arrowClockwise)
                        .padding(.horizontal)
                        .font(.subheadline.bold().monospaced())
                        .hoverEffect()

                }).padding().buttonStyle(.refresh).clipped()
            }
        }
        .padding().symbolRenderingMode(.hierarchical)
    }
}

#Preview(body: {
    ContentUnavailableView<Image>("No Results",
                                  symbol: SFSymbol.battery100BoltRtl,
                                  description: "Content Unavailable View Decription \n In this implementation, the ContentUnavailableView is a generic view that takes a Content view as a trailing closure. It displays a title, message, and an image, along with the provided content view.",
                                  content: {
                                      SFSymbol.magnifyingglass.image
                                  })
})

// Example usage
struct ContentUnavailablePreview: View {
    @State private var searchText = ""
    @State private var searchResults: [String] = []
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(searchText: $searchText, placeholder: "Try a enter search term")

                if searchText.isEmpty {
                    // Show regular content
                } else {
                    // Show search results or empty view
                    if searchResults.isEmpty {
                        ContentUnavailableView("No Results", message: "Try a different search term", image: Image(systemName: "magnifyingglass"), content: {
                            // Add any additional content or actions here
                            EmptyView()
                        })
                    } else {
                        // Show search results
                    }
                }
            }
            .navigationTitle("Search")
        }
    }
}
