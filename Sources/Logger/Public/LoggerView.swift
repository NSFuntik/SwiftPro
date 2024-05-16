import SwiftUI

///
public struct LoggerView: View {
    @StateObject private var logger: SwiftUILogger
    @State private var isMinimal: Bool = false
    @State private var isPresentedFilter: Bool = false
    
    private var logs: [SwiftUILogger.Event] { logger.displayedLogs }
    
    private var tags: Set<String> {
        Set(
            logger.logs
                .flatMap { $0.metadata.tags }
                .map { $0.value }
        )
    }
    
    private var navigationTitle: String {
        "\(logs.count) \(logger.name.map { "\($0) " } ?? "")Events"
    }
    
    private let shareAction: (String) -> Void
    
    ///
    public init(
        logger: SwiftUILogger = .default,
        shareAction: @escaping (String) -> Void = { print($0) }
    ) {
        self._logger = StateObject(wrappedValue: logger)
        self.shareAction = shareAction
    }
    
    ///
    public var body: some View {
        navigation {
            Group {
                if logs.isEmpty {
                    Text("Logs will show up here!")
                        .font(.largeTitle)
                } else {
                    ScrollViewReader { proxy in
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                let logCount = logs.count - 1
                                ForEach(0 ... logCount, id: \.self) { index in
                                    let log = logs[logCount - index]
                                    
                                    LogEventView(
                                        event: log,
                                        isMinimal: isMinimal
                                    )
                                    .padding(.horizontal, 4)
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous), style: .init(eoFill: true, antialiased: true))
                                    .background {
                                        let color = Color(index.isMultiple(of: 2) ? .secondarySystemGroupedBackground : .tertiarySystemBackground)
                                        if #available(iOS 16.0, *) {
                                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                .fill(color.shadow(.inner(color: log.level.color, radius: 1.06)).shadow(.drop(color: Color(.opaqueSeparator), radius: 1.66)))
                                        } else {
                                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                .fill(color)
                                        }
                                    }
                                    Divider()
                                }
                                
                            }.padding(1)
                            Spacer(minLength: 66)
                        }
                        .overlay(alignment: .bottomTrailing) {
                            Button {
                                withAnimation(.smooth) {
                                    proxy.scrollTo(logs.count - 1, anchor: .bottom)
                                }
                            } label: {
                                Image(systemName: "arrow.down.circle.dotted")
                                    .imageScale(.large)
                                    .font(.title)
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.purple)
                                    .padding(8)
                                    .background(.ultraThinMaterial, in: Circle())
                                    .padding(12)
                                    .shadow(radius: 3)
                            }
                        }
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                HStack {
                    shareBlobButton
                    filterButton
                    toggleMinimalButton
                }
                .disabled(logs.isEmpty)
            }
            .background(Color(.lightGray).opacity(0.16))
        }
    }
    
    @ViewBuilder
    private func navigation(content: () -> some View) -> some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                content()
            }
        } else {
            NavigationView {
                content()
            }
        }
    }
    
    private var shareBlobButton: some View {
        Button(
            action: {
                shareAction(logger.blob)
            },
            label: {
                Image(systemName: "square.and.arrow.up")
            }
        )
    }
    
    private var filterButton: some View {
        Button(
            action: {
                withAnimation {
                    isPresentedFilter.toggle()
                }
            },
            label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        )
        .sheet(isPresented: $isPresentedFilter) {
            LogFilterView(
                logger: logger,
                tags: Array(tags),
                isPresented: $isPresentedFilter
            )
        }
    }
    
    private var toggleMinimalButton: some View {
        Button(
            action: {
                withAnimation {
                    isMinimal.toggle()
                }
            },
            label: {
                Image(systemName: isMinimal ? "list.bullet.circle" : "list.bullet.circle.fill")
            }
        )
    }
}

struct LoggerView_Previews: PreviewProvider {
    static var previews: some View {
        LoggerView(
            logger: SwiftUILogger(
                name: "Preview",
                logs: [
                    .init(level: .success, message: "Accessing Environment<ChatTheme>'s value outside of being installed on a View. This will always read the default value and will not update."),
                    .init(level: .warning, message: "init"),
                    .init(level: .trace, message:
                        """
                          􁇵INFO: {
                            "stage" : "setup",
                            "status" : "complete" }
                        """),
                    .init(level: .error, message:
                        """
                        - nil
                        ▿ Optional(FlomniChatSDK.SocketChatEvent)
                        ▿ some: FlomniChatSDK.SocketChatEvent #0
                        ▿ super: FlomniChatSDK.ChatEvent
                        - type: "gtm-event"
                        - id: "E95F0D0E-F806-42D3-B561-1D9016EE6820"
                        ▿ event: Optional(FlomniChatSDK.SEvent.gtmEvent)
                        - some: FlomniChatSDK.SEvent.gtmEvent
                        - eventId: nil
                        - mid: nil
                        - time: nil
                        - avatarUrl: nil
                        ▿ name: Optional("intro")
                        - some: "intro"
                        - title: nil
                        - timeout: nil
                        - agentId: nil
                        - originator: nil
                        - threadId: nil
                        - stage: nil
                        """),
                    .init(level: .info, message: "init"),
                    .init(level: .fatal, message: "init"),
                    .init(level: .debug, message: "init"),
                ]
            )
        )
    }
}
