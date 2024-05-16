import Factory
import SwiftUI
import CoreAudio

#Preview(body: {
    @State var output: UIImage? = nil
    
    return CameraView($output).task {
        await (AudioFeedback(audio: .busyToneANSI).perform())
    }
})

public extension AnyFeedback {
    /// Specifies feedback that plays an audio file
    /// - Parameter audio: The audio to play when this feedback is triggered
    static func audio(_ audio: Audio) -> Self {
        .init(AudioFeedback(audio: audio))
    }
}

public extension View {
    /// Specifies feedback that plays an audio file
    /// - Parameter audio: The audio to play when this feedback is triggered
    func audio(_ audio: Audio) -> some View {
        self.modifier(AudioFeedback(audio: audio))
    }
}

public extension Audio {
    @MainActor
    func play() async throws {
        try await AudioPlayer.shared.play(audio: self)
    }
}

public struct AudioPlayerEnvironmentKey: EnvironmentKey {
    @MainActor public static let defaultValue: AudioPlayer = AudioPlayer.shared
}

public extension SharedContainer {
    @MainActor var audioPlayer: Factory<AudioPlayer> {
        self { AudioPlayerEnvironmentKey.defaultValue }.singleton
    }
}

public struct AudioFeedback: Feedback, ViewModifier {
    @Injected(\.audioPlayer) private var player
    
    public func body(content: Content) -> some View {
        content
            .task(id: audio.hashValue, {
                try? await player.play(audio: audio)
            })
    }
    
    @State var audio: Audio
    
    init(audio: Audio) {
        self._audio = State(wrappedValue: audio)
    }
    
    @MainActor
    public func perform() async {
        do {
            try await player.play(audio: audio)
        } catch {
            debugPrint("Error playing audio", error)
        }
    }
}
