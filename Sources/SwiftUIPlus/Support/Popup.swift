//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 09.04.2024.
//

import SwiftUI

public extension View {
    func popup<PopupContent: View, Item: Hashable>(
        alignment: Alignment,
        item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> PopupContent
    ) -> some View {
        self
            .clipped()
            .modifier(Popup(alignment: alignment, item: item, content: content))
    }
}

struct Popup<PopupContent: View, Item: Hashable>: ViewModifier {
    @Environment(\.dismiss) var dismiss
    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                Group {
                    if let item = self.item {
                        popup(item)
                            .saveSize(in: $size)
                            .offset(y: offset)
                            .gesture(
                                DragGesture()
                                    .onChanged({ value in
                                        if alignment == .bottom {
                                            if value.translation.height < size.height {
                                                withAnimation {
                                                    offset = value.translation.height
                                                }
                                            }
                                        } else if alignment == .top {
                                            if value.translation.height > -size.height {
                                                withAnimation {
                                                    offset = value.translation.height
                                                }
                                            }
                                        }
                                    })
                                    .onEnded({ _ in
                                        withAnimation {
                                            if alignment == .bottom {
                                                if offset <= size.height / 2 {
                                                    offset = 0
                                                } else {
                                                    self.item = .none
                                                    
                                                    offset = 0
                                                }
                                            } else if alignment == .top {
                                                if offset >= -size.height / 2 {
                                                    offset = 0
                                                } else {
                                                    self.item = .none
                                                    offset = 0
                                                }
                                            }
                                        }
                                    })
                            )
                    }
                }
                .padding(16, 12)
                .onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.20, execute: {
                        self.item = .none
                        dismiss()
                    })
                })
            }
            .animation(.interactiveSpring, value: offset)
            .animation(.bouncy(duration: 0.3), value: size)
            .transition(.move(edge: alignment == .bottom ? .bottom : .top).combined(with: .offset(y: alignment == .bottom ? -100 : 100)).animation(.bouncy))
            .clipped()
            .background(.clear)
    }
    
    @State var popup: (Item) -> PopupContent
    @Binding var item: Item?
    
    @State private var offset: CGFloat = .zero
    @State private var size: CGSize = .zero
    
    let alignment: Alignment
    
    init(
        alignment: Alignment = .top,
        item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> PopupContent
    ) {
        self.alignment = alignment
        self._item = item
        self.popup = content
    }
}

extension View {
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: size))
    }
}

/// A view modifier for calculating the size of a view and updating a binding with the result.
///
/// The `SizeCalculator` view modifier is used to calculate the size of a view and update a binding with the size result. This can be helpful in scenarios where you need to determine the size of a view and use it in your layout or animations.
///
///
/// - Parameters:
///   - size: A binding to a `CGSize` that will be updated with the size of the view.
struct SizeCalculator: ViewModifier {
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .ignoresSafeArea(.all)
                        .onAppear {
                            size = proxy.size
                        }
                }
            )
    }
}
