//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 15.03.2024.
//

import SwiftUI
import SwiftUIBackports

struct BackdropBlurView<S: Shape>: ViewModifier {
    init(
        style: UIBlurEffect.Style = .systemUltraThinMaterialLight,
        blur radius: CGFloat = 6,
        shape: S = RoundedRectangle(cornerRadius: 0, style: .continuous),
        filled tint: Color = .clear,
        bordered stroke: Color = .clear,
        by width: CGFloat = 0
    ) {
        self.style = style
        self.radius = radius
        self.tint = tint
        self.shape = shape
        self.stroke = stroke
        self.width = width
    }
    
    let style: UIBlurEffect.Style
    let radius: CGFloat
    var tint: Color = Color.secondary.opacity(0.5)
    var shape: S
    var stroke: Color
    var width: CGFloat
    
    @ViewBuilder
    func body(content: Content) -> some View where S: Shape {
        content
            .background {
                shape.fill(tint)
                    .background(MaterialEffect(with: style).blur(radius: radius))
                    .background(shape.stroke(lineWidth: width / 2)
                        .fill(stroke)
                        .blur(radius: radius))
                    .overlay(shape
                        .stroke(lineWidth: width)
                        .fill(stroke, style: FillStyle(antialiased: true)))
                    .padding(width)
                    .clipShape(shape, style: FillStyle(antialiased: true))
            }
    }
}

private struct MaterialEffect: UIViewRepresentable {
    let style: UIBlurEffect.Style
    init(with style: UIBlurEffect.Style = .systemMaterial) {
        self.style = style
    }
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(),
                                                               style: .tertiaryFill))
        let blur = UIBlurEffect(style: style)
        let animator = UIViewPropertyAnimator()
        animator.addAnimations {
            view.superview?.superview?.backgroundColor = .clear
            view.effect = blur
        }
        animator.fractionComplete = 0
        animator.stopAnimation(false)
        animator.finishAnimation(at: .current)
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }
}

public extension View {
    @ViewBuilder
    func materialBackground<S>(
        with style: UIBlurEffect.Style = .systemMaterialDark,
        blur radius: CGFloat = 1,
        clipped shape: S = RoundedRectangle(cornerRadius: 0, style: .continuous),
        filled tint: Color = .black.opacity(0.11),
        bordered stroke: Color = .clear,
        width: CGFloat = 0
    ) -> some View where S: Shape {
        modifier(BackdropBlurView(
            style: style,
            blur: radius,
            shape: shape,
            filled: tint,
            bordered: stroke,
            by: width
        ))
    }
}
//chatTheme.generalColors.$chatBackgroundColor.overlay(
//    Image("Pattern", bundle: .module)
//        .resizable(resizingMode: .tile)
//    .foregroundStyle(chatTheme.generalColors.$inputHintColor.opacity(0.77))).ignoresSafeArea(.all)
