import SwiftUI

/// View that observes its position within a given coordinate space,
/// and assigns that position to the specified Binding.
public struct PositionObservingView<Content: View>: View {
    var coordinateSpace: CoordinateSpace
    @Binding var position: CGPoint
    var content: Content

    public init(
        coordinateSpace: CoordinateSpace,
        position: Binding<CGPoint>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.coordinateSpace = coordinateSpace
        self._position = position
        self.content = content()
    }

    public var body: some View {
        content
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: PreferenceKey.self,
                    value: geometry.frame(in: coordinateSpace).origin
                )
            })
            .onPreferenceChange(PreferenceKey.self) { position in
                self.position = position
            }
    }
}

private extension PositionObservingView {
    enum PreferenceKey: SwiftUI.PreferenceKey {
        static var defaultValue: CGPoint { .zero }

        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
            debugPrint("reduce(value: \(String(describing: reduce)), nextValue: \(nextValue())")
        }
    }
}

/// Specialized scroll view that observes its content offset (scroll position)
/// and assigns it to the specified Binding.
public struct OffsetObservingScrollView<Content: View>: View {
    var axes: Axis.Set = [.vertical]
    var showsIndicators = true
    @Binding var offset: CGPoint
    var content: Content

    private let coordinateSpaceName = UUID()
    public init(
        axes: Axis.Set,
        showsIndicators: Bool = true,
        offset: Binding<CGPoint>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self._offset = offset
        self.content = content()
    }

    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            PositionObservingView(
                coordinateSpace: .named(coordinateSpaceName),
                position: Binding(
                    get: { offset },
                    set: { newOffset in
                        offset = CGPoint(
                            x: -newOffset.x,
                            y: -newOffset.y
                        )
                    }
                ),
                content: { content }
            )
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
}

#Preview(body: {
    /// View that renders scrollable content beneath a header that
    /// automatically collapses when the user scrolls down.
    struct ContentView<Content: View>: View {
        var collapsedHeaderOpacity: CGFloat {
            let minOpacityOffset = headerHeight.expanded / 2
            let maxOpacityOffset = headerHeight.expanded - headerHeight.collapsed

            guard scrollOffset.y > minOpacityOffset else { return 0 }
            guard scrollOffset.y < maxOpacityOffset else { return 1 }

            let opacityOffsetRange = maxOpacityOffset - minOpacityOffset
            return (scrollOffset.y - minOpacityOffset) / opacityOffsetRange
        }

        var headerLinearGradient: LinearGradient {
            LinearGradient(
                gradient: headerGradient,
                startPoint: .top,
                endPoint: .bottom
            )
        }

        func makeHeaderText(collapsed: Bool) -> some View {
            Text(title)
                .font(collapsed ? .body : .title)
                .lineLimit(1)
                .padding()
                .frame(height: collapsed ? headerHeight.collapsed : headerHeight.expanded)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .accessibilityHeading(.h1)
                .accessibilityHidden(collapsed)
        }

        var title: String
        var headerGradient: Gradient
        @ViewBuilder var content: () -> Content

        private let headerHeight = (collapsed: 50.0, expanded: 150.0)
        @State private var scrollOffset = CGPoint()

        var body: some View {
            GeometryReader { geometry in
                OffsetObservingScrollView(axes: .vertical, offset: $scrollOffset) {
                    VStack(spacing: 0) {
                        makeHeaderText(collapsed: false)
                        content()
                    }
                }
                .overlay(alignment: .top) {
                    makeHeaderText(collapsed: true)
                        .background(alignment: .top) {
                            headerLinearGradient.ignoresSafeArea()
                        }
                        .opacity(collapsedHeaderOpacity)
                }
                .background(alignment: .top) {
                    // We attach the expanded header's background to the scroll
                    // view itself, so that we can make it expand into both the
                    // safe area, as well as any negative scroll offset area:
                    headerLinearGradient
                        .frame(height: max(0, headerHeight.expanded - scrollOffset.y) + geometry.safeAreaInsets.top)
                        .ignoresSafeArea()
                }
            }
        }
    }
    return ContentView(
        title: "Title",
        headerGradient: Gradient(colors: [.red, .blue]),
        content: {
            ContentUnavailableView(
                "Content",
                symbol: .listBullet,
                description: "We attach the expanded header's background to the scroll view itself, so that we can make it expand into both the safe area, as well as any negative scroll offset area:", content: {
                    ForEach(0 ..< 10) { i in
                        Text("Item").id(i)
                    }
                })

            Text("Content")
        }
    )
})
