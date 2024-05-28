
import SwiftUI

public struct AsyncButton<Label: View, Trigger: Equatable>: View {
    var cancellation: Trigger?
    let action: () async -> Void
    let label: Label

    @State private var task: Task<Void, Never>?
    @State private var isRunning = false

    init(
        cancellation: Trigger = false,
        action: @escaping () async -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.cancellation = cancellation
        self.action = action
        self.label = label()
    }

    init(
        cancellation: Trigger = false,
        action: Void,
        @ViewBuilder label: () -> Label
    ) {
        self.cancellation = cancellation
        self.action = { action }
        self.label = label()
    }

    public var body: some View {
        Button {
            isRunning = true
            task = Task {
                await action()
                isRunning = false
            }
        } label: {
            label
        }
        .disabled(isRunning)
        .opacity(isRunning ? 0.5 : 1)
        .shimmering(active: isRunning)
        .if(isRunning, { $0.overlay(alignment: .center, content: { ProgressView().progressViewStyle(.circular).padding() }) })

        .onChange(of: cancellation) { _ in
            task?.cancel()
        }
    }
}

public extension AsyncButton where Trigger == Never {
    init(
        action: @escaping () async -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }
}
