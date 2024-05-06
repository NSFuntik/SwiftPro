import SwiftUI

private struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

private struct FrameChangeModifier: ViewModifier {
    let coordinateSpace: CoordinateSpace
    let handler: (CGRect) -> Void

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader {
                    Color.clear.preference(
                        key: FramePreferenceKey.self,
                        value: $0.frame(in: coordinateSpace)
                    )
                }
            )
            .onPreferenceChange(FramePreferenceKey.self) {
                guard !$0.isEmpty else { return }
                handler($0)
            }
    }
}

public extension View {
    func onFrameChange(coordinateSpace: CoordinateSpace = .global, _ handler: @escaping (CGRect) -> Void) -> some View {
        modifier(FrameChangeModifier(coordinateSpace: coordinateSpace, handler: handler))
    }
}



/// Scroll Content Offset
public struct OffsetKey: PreferenceKey {
    public static var defaultValue: CGRect = .zero
    
    public static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

public extension View {
    @ViewBuilder
    func offset(_ coordinateSpace: AnyHashable, completion: @escaping (CGRect) -> Void) -> some View {
        overlay {
            GeometryReader {
                let rect = $0.frame(in: .named(coordinateSpace))
                
                Color.clear
                    .preference(key: OffsetKey.self, value: rect)
                    .onPreferenceChange(OffsetKey.self) { newRect in
                        Task {
                            await MainActor.run {
                                completion(newRect)
                            }
                        }
                    }
            }
        }
    }
}

fileprivate struct AnimationEndedCallback<Value: VectorArithmetic>: Animatable, ViewModifier {
    var animatableData: Value {
        didSet {
            checkIfFinished()
        }
    }
    
    var endValue: Value
    var onEnd: () -> Void
    
    init(for value: Value, onEnd: @escaping () -> Void) {
        animatableData = value
        endValue = value
        self.onEnd = onEnd
    }
    
    func body(content: Content) -> some View {
        content
    }
    
    private func checkIfFinished() {
        if endValue == animatableData {
            DispatchQueue.main.async {
                onEnd()
            }
        }
    }
}

public extension View {
    @ViewBuilder
    func checkAnimationEnded<Value: VectorArithmetic>(for value: Value, onEnd: @escaping () -> Void) -> some View {
        modifier(AnimationEndedCallback(for: value, onEnd: onEnd))
    }
}
