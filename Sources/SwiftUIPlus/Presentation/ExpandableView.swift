import SwiftUI
public struct DroppableView: View {
    @Namespace private var namespace
    @State private var show = false

    var thumbnail: Thumbnail
    var expanded: Expanded

    var thumbnailViewBackgroundColor: Color = .gray.opacity(0.8)
    var expandedViewBackgroundColor: Color = .gray

    var thumbnailViewCornerRadius: CGFloat = 6
    var expandedViewCornerRadius: CGFloat = 6
    public init(thumbnail: Thumbnail, expanded: Expanded, thumbnailViewBackgroundColor: Color = Color(.tertiarySystemGroupedBackground), expandedViewBackgroundColor: Color  = Color(.systemGroupedBackground), thumbnailViewCornerRadius: CGFloat = 6, expandedViewCornerRadius: CGFloat = 6) {
        self.thumbnail = thumbnail
        self.expanded = expanded
        self.thumbnailViewBackgroundColor = thumbnailViewBackgroundColor
        self.expandedViewBackgroundColor = expandedViewBackgroundColor
        self.thumbnailViewCornerRadius = thumbnailViewCornerRadius
        self.expandedViewCornerRadius = expandedViewCornerRadius
    }
    public var body: some View {
        ZStack {
            if !show {
                thumbnailView()
            } else {
                expandedView()
            }
        }
        .onTapGesture {
            if !show {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    show.toggle()
                }
            }
        }
    }

    @ViewBuilder
    private func thumbnailView() -> some View {
        ZStack {
            thumbnail
                .matchedGeometryEffect(id: "view", in: namespace)
        }
        .background(
            thumbnailViewBackgroundColor.matchedGeometryEffect(id: "background", in: namespace)
        )
        .mask(
            RoundedRectangle(cornerRadius: thumbnailViewCornerRadius, style: .continuous)
                .matchedGeometryEffect(id: "mask", in: namespace)
        )
    }

    @ViewBuilder
    private func expandedView() -> some View {
        ZStack {
            expanded
                .matchedGeometryEffect(id: "view", in: namespace)
                .background(
                    expandedViewBackgroundColor
                        .matchedGeometryEffect(id: "background", in: namespace)
                )
                .mask(
                    RoundedRectangle(cornerRadius: expandedViewCornerRadius, style: .continuous)
                        .matchedGeometryEffect(id: "mask", in: namespace)
                )

            Button {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    show.toggle()
                }
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .matchedGeometryEffect(id: "mask", in: namespace)
        }
    }

    public struct Thumbnail: View, Identifiable {
        public var id = UUID()
        @ViewBuilder public var content: any View

        public var body: some View {
            ZStack {
                AnyView(content)
            }
        }
    }

    public struct Expanded: View, Identifiable {
        public var id = UUID()
        @ViewBuilder public var content: any View

        public var body: some View {
            ZStack {
                AnyView(content)
            }
        }
    }
}
