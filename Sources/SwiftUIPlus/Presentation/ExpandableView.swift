import SwiftUI

public struct ExpandableView: View {
    @Namespace private var namespace
    @State private var show = false

    var thumbnail: ThumbnailView
    var expanded: ExpandedView

    @ViewBuilder var background: (() -> any View)

    var thumbnailViewCornerRadius: CGFloat = 20
    var expandedViewCornerRadius: CGFloat = 20

    public init(
        @ViewBuilder thumbnail: () -> some View,
        @ViewBuilder expanded: () -> some View,
        @ViewBuilder background: @escaping () -> some SwiftUI.View = { EmptyView().background(.regularMaterial.blendMode(.exclusion)) }
    ) {
        self.thumbnail = ThumbnailView(content: thumbnail)
        self.expanded = ExpandedView(content: expanded)
        self.background = background
    }

    public var body: some View {
        Button(role: .destructive) {
            if !show {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    show.toggle()
                }
            }
        } label: {
            ZStack {
                if !show {
                    thumbnailView()
                } else {
                    expandedView()
                }
            }
        }

//
//
//        .onTapGesture {
//
//        }
    }

    @ViewBuilder
    private func thumbnailView() -> some View {
        ZStack {
            thumbnail
                .matchedGeometryEffect(id: "view", in: namespace)
        }

        .background(
            background().matchedGeometryEffect(id: "background", in: namespace))

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
                    background().opacity(0.8).matchedGeometryEffect(id: "background", in: namespace))

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
    
    public struct ThumbnailView: View, Identifiable {
        public var id = UUID()
        @ViewBuilder var content: any View
     
        public var body: some View {
            ZStack {
                AnyView(content)
            }
        }
    }
    
    public struct ExpandedView: View {
        public var id = UUID()
        @ViewBuilder var content: any View
       
        public var body: some View {
            ZStack {
                AnyView(content)
            }
        }
    }
}

