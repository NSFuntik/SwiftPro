//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 02.05.2024.
//

import Photos
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
		}, content: {
			EmptyView()
		}
	)

#Preview(body: {
	let messenger = ChannelServerData(id: "5d0cd1707741de0009e061cb_tlgr_yappy_bot", messenger: .tlgr, visible: true, link: "https://t.me/yappy_bot?start=", idx: 0)

	return ContentUnavailableView(
		"Привет 👋",
		message: "Мы помогаем вашему бизнесу расти, связывая вас с вашими клиентами.",
		image: Image("DialogsLogo"),
		actionTitle: "Отправить сообщение",
		actionSymbol: .paperplane,
		action: {},
		content: {
			VStack(alignment: .leading, spacing: 8) {
				Text("Поговорите с нами в любимом канале")
					.font(.system(.title3, .rounded, .semibold))
					.foregroundStyle(.black)
					.highlightEffect()

				Text("Вы можете общаться в любимом канале на любом устройстве, будь то ноутбук, планшет или мобильный телефон.")
					.font(.subheadline).multilineTextAlignment(.leading)
					.foregroundStyle(.secondary)
				if let link = messenger.link,
				   let url = URL(string: link)
				{
					Link(destination: url) {
						Label(messenger.messenger?.description.capitalized ?? "Telegram", image: messenger.messenger?.icon ?? "Telegram")
							.imageScale(.large)
							.font(.body.monospaced().bold())
							.foregroundStyle(.foreground)
							.padding(8, 16)
							.background(.ultraThinMaterial)
							.cornerRadius(8).shadow(.sticker)
					}
				}
			}.padding(16).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16)).clipped()
		}
	).patternBackground().saturation(1.62).clipShape(RoundedRectangle(cornerRadius: 16))
})
public extension ContentUnavailableView where Content == EmptyView {
	init(
		_ title: String,
		subheadline: String,
		symbol: SFSymbol,
		actionTitle: String = "Retry",
		actionSymbol: SFSymbol = .arrowClockwise,
		action: (() -> Void)? = nil
	) where Content == EmptyView {
		self.title = title
		self.message = subheadline
		self.image = symbol.image
		self.content = nil
		self.actionTitle = actionTitle
		self.actionSymbol = actionSymbol
		self.action = action
	}

	init(
		_ title: String,
		subheadline: String,
		image: Image,
		actionTitle: String = "Retry",
		actionSymbol: SFSymbol = .arrowClockwise,
		action: (() -> Void)? = nil
	) where Content == EmptyView {
		self.title = title
		self.message = subheadline
		self.image = image
		self.content = nil
		self.actionTitle = actionTitle
		self.actionSymbol = actionSymbol
		self.action = action
	}
}

// MARK: - ContentUnavailableView

@available(iOS, introduced: 14.0, deprecated: 16.0, renamed: "ContentUnavailableView")
public struct ContentUnavailableView<Content>: View where Content: View {
	let title: String
	let message: String
	let image: Image
	var content: (() -> Content)?
	var actionTitle = "Retry"
	var actionSymbol: SFSymbol = .arrowClockwise
	let action: (() -> Void)?
	@Environment(\.refresh) var refresh
	@Environment(\.dismiss) var dismiss

	public init(
		_ title: String,
		message: String,
		image: Image,
		actionTitle: String = "Retry",
		actionSymbol: SFSymbol = .arrowClockwise,
		action: (() -> Void)? = nil,
		@ViewBuilder content: @escaping () -> Content
	) {
		self.title = title
		self.message = message
		self.image = image
		self.content = content
		self.actionTitle = actionTitle
		self.actionSymbol = actionSymbol
		self.action = action
	}

	public init(
		_ title: String,
		image: SFSymbol,
		actionTitle: String = "Retry",
		actionSymbol: SFSymbol = .arrowClockwise,
		action: (() -> Void)? = nil,
		@ViewBuilder content: @escaping () -> Content
	) {
		self.title = title
		self.message = ""
		self.image = image.image
		self.actionTitle = actionTitle
		self.actionSymbol = actionSymbol
		self.content = content
		self.action = action
	}

	public init(
		_ title: String,
		symbol: String,
		actionTitle: String = "Retry",
		actionSymbol: SFSymbol = .arrowClockwise,
		action: (() -> Void)? = nil,
		@ViewBuilder content: @escaping () -> Content
	) {
		self.title = title
		self.message = ""
		self.image = Image(systemName: symbol)
		self.actionTitle = actionTitle
		self.actionSymbol = actionSymbol
		self.content = content
		self.action = action
	}

	public init(
		_ title: String,
		symbol: SFSymbol,
		description: String,
		actionTitle: String = "Retry",
		actionSymbol _: SFSymbol = .arrowClockwise,
		action: (() -> Void)? = nil,
		@ViewBuilder content: @escaping () -> Content
	) {
		self.title = title
		self.message = description
		self.image = symbol.image
		self.content = content
		self.actionTitle = actionTitle
		self.action = action
	}

	public var body: some View {
		VStack(alignment: .center, spacing: 16) {
			image
				.font(.largeTitle)
				.imageScale(.large)
			Text(title)
				.font(.system(.title, .rounded, .bold))
				.multilineTextAlignment(.center).foregroundStyle(.primary)

			Text(message)
				.font(.system(.subheadline, .rounded, .medium))
				.multilineTextAlignment(.center).foregroundStyle(.secondary)
				.highlightEffect()
			content?()
			AsyncButton {
				if let action {
					action()
					return
				}
				await refresh?()
			} label: {
				Label(.init(actionTitle.isEmpty ? "Refresh" : actionTitle), symbol: actionSymbol)
					.font(.system(.headline, .rounded, .medium))
					.padding(2, 8)
					.hoverEffect()
			}

			.padding().buttonStyle(.refresh).clipped()
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

// MARK: - ContentUnavailablePreview

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
