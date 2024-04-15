import SwiftUI

public extension AnyFeedback {
    /// Specifies feedback that plays an audio file
    /// - Parameter audio: The audio to play when this feedback is triggered
    static func audio(_ audio: Audio) -> Self {
        .init(AudioFeedback(audio: audio))
    }
}

public struct AudioPlayerEnvironmentKey: EnvironmentKey {
    public static var defaultValue: AudioPlayer = .init()
}

public extension EnvironmentValues {
    var audioPlayer: AudioPlayer {
        get { self[AudioPlayerEnvironmentKey.self] }
        set { self[AudioPlayerEnvironmentKey.self] = newValue }
    }
}

public struct AudioFeedback: Feedback, ViewModifier {
    @Environment(\.audioPlayer) private var player

    public func body(content: Content) -> some View {
        content
            .environmentObject(player)
    }

    var audio: Audio

    init(audio: Audio) {
        self.audio = audio
    }

    @MainActor
    public func perform() async {
        do {
            try await player.play(audio: audio)
        } catch {
            print(error)
        }
    }
}
