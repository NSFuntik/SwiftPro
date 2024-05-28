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

    @ViewBuilder
    func popup<PopupContent: View, Item: Hashable>(popup: Binding<Popup<PopupContent, Item>?>) -> some View {
        if let popup = popup.wrappedValue {
            self
                .popup(alignment: popup.alignment, item: popup.$item) { item in
                    popup.$popup.wrappedValue(item)
                }
        } else { self }
    }

    func popup<PopupContent: View>(
        alignment: Alignment,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping (Bool) -> PopupContent
    ) -> some View {
        self
            .clipped()
            .modifier(Popup(alignment: alignment, isPresented: isPresented, content: content))
    }
}

public struct Popup<PopupContent: View, Item: Hashable>: ViewModifier, Hashable {
    public static func == (lhs: Popup<PopupContent, Item>, rhs: Popup<PopupContent, Item>) -> Bool {
        return lhs.alignment == rhs.alignment && lhs.item == rhs.item && lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(item)
        hasher.combine(offset)
    }

    var shouldDismiss: Bool = true

    @ViewBuilder
    public func body(content: Content) -> some View {
        ZStack(alignment: alignment) {
            content
                
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
                        .onAppear(perform: {
                            if shouldDismiss {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                                    self.item = .none
                                })
                            }

                        })
                }
            }
            .padding(16, 12)
            
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
        self._popup = State(wrappedValue: content)
    }
    
    init(
        alignment: Alignment = .top,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping (Bool) -> PopupContent
    ) where Item == Bool {
        self.alignment = alignment
        self.shouldDismiss = false
        self._item = .init(get: {
            let bool: Bool? = isPresented.wrappedValue
            return bool
        }, set: { item in
            guard let _ = item else { isPresented.wrappedValue = false; return }
            isPresented.wrappedValue = true
        })
        self._popup = State(wrappedValue: content)
    }
}

public extension View {
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
public struct SizeCalculator: ViewModifier {
    @Binding var size: CGSize

    public func body(content: Content) -> some View {
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
