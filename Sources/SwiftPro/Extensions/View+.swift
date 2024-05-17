//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 27.02.2024.
//

import SwiftUI

public extension View {
    /// Applies a modifier to a view conditionally.
    ///
    /// - Parameters:
    ///   - condition: The condition to determine if the content should be applied.
    ///   - content: The modifier to apply to the view.
    /// - Returns: The modified view.

    @ViewBuilder @inlinable
    func `if`<T>(
        _ condition: @autoclosure () -> Bool,
        _ transform: (Self) -> T)
        -> some View where T: View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder @inlinable
    func `if`<T, _T>(
        _ condition: @autoclosure () -> Bool,
        _ transform: (Self) -> T,
        else _transform: (Self) -> _T
    ) -> some View where T: View, _T: View {
        if condition() {
            transform(self)
        } else {
            _transform(self)
        }
    }

    @inlinable
    func frame(box: CGFloat) -> some View { frame(width: box, height: box, alignment: .center) }

    @inlinable
    func frame(_ size: CGSize) -> some View { frame(width: size.width, height: size.height, alignment: .center) }

    @inlinable
    func color(_ color: Color) -> some View {
        if #available(iOS 14, *) {
            return foregroundStyle(AnyShapeStyle(color))
        } else {
            return foregroundColor(color)
        }
    }

    @inlinable
    func foregroundStyle(_ color: Color) -> some View {
        if #available(iOS 14, *) {
            return foregroundStyle(AnyShapeStyle(color))
        } else {
            return foregroundColor(color)
        }
    }

    @inlinable
    func padding(_ vertical: CGFloat, _ horizontal: CGFloat) -> some View {
        padding(.vertical, vertical)
            .padding(.horizontal, horizontal)
    }

    ///

    @inlinable func backgroundStyled<S>(_ style: S) -> some View where S: ShapeStyle {
        if #available(iOS 16, *) {
            return backgroundStyle(style)
        } else {
            return background(style)
        }
    }

    @ViewBuilder @inlinable
    func hidden(_ isHidden: Bool) -> some View {
        if isHidden {
            hidden()
        } else {
            self
        }
    }

    @inlinable
    func spacing() -> some View { modifier(Spacing()) }
}

public struct Spacing: ViewModifier {
    @inlinable
    public init() { }
    @ViewBuilder
    public func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
        }
    }
}

public extension Font {
    static func system(
        _ style: Font.TextStyle = .body,
        _ design: Font.Design = .default,
        _ weight: Font.Weight = .regular
    ) -> Font {
        if #available(iOS 16.0, *) {
            return SwiftUI.Font.system(style, design: design, weight: weight)
        } else {
            return .system(style, design: design).weight(weight)
        }
    }

    static func system(
        _ style: Font.TextStyle = .body,
        _ weight: Font.Weight = .regular
    ) -> Font {
        if #available(iOS 16.0, *) {
            return SwiftUI.Font.system(style, design: .default, weight: weight)
        } else {
            return .system(style, design: .default).weight(weight)
        }
    }
}

/**
 A `UIColor` extension that provides functionality for generating adaptive colors based on a seed string.
 - Author: Your Name
 */
public extension UIColor {
    /**
     Generates a light color based on a seed string.
     - Parameters:
     - seed: A string used as a seed for random color generation.
     - Returns: A `UIColor` object representing the generated color.
     */
    fileprivate class func lightColor(withSeed seed: String) -> UIColor {
        // Generate a light color
        srand48(seed.hash)

        let hue = CGFloat(drand48())
        let saturation = CGFloat(0.5)
        let brightness = CGFloat(1.0 - 0.25 * drand48())

        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }

    /**
     Generates a dark color based on a seed string.
     - Parameters:
     - seed: A string used as a seed for random color generation.
     - Returns: A `UIColor` object representing the generated color.
     */
    fileprivate class func darkColor(withSeed seed: String) -> UIColor {
        // Generate a dark color
        srand48(seed.hash)

        let hue = CGFloat(drand48())
        let saturation = CGFloat(0.5)
        let brightness = CGFloat(0.3 + 0.25 * drand48())

        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }

    /**
     // Generates an adaptive color that adapts to the user interface style
     - Parameters:
     - seed: A string used as a seed for random color generation.
     - Returns: A `UIColor` object representing the generated adaptive color.
     */
    class func adaptiveColor(withSeed seed: String) -> UIColor {
        let light = lightColor(withSeed: seed)
        let dark = darkColor(withSeed: seed)

        return UIColor { traitCollection -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return dark
            }

            return light
        }
    }
}

extension Color {
    @inlinable
    public static func adaptiveColor(withSeed seed: String) -> Color {
        Color(UIColor.adaptiveColor(withSeed: seed))
    }

    public init(adaptWithSeed: String) {
        self.init(UIColor.adaptiveColor(withSeed: adaptWithSeed))
    }

  
}

public extension View {
    @ViewBuilder
    func highlightEffect() -> some View {
        if #available(iOS 15, *) {
            contentShape(.hoverEffect, RoundedRectangle(cornerRadius: 13, style: .continuous).inset(by: -20))
                .hoverEffect(.highlight)
        } else {
            hoverEffect(.highlight)
        }
    }

    @ViewBuilder
    func ignoreKeyboard() -> some View {
        if #available(iOS 14, *) {
            ignoresSafeArea(.keyboard, edges: .all)
        } else {
            self
        }
    }

    @ViewBuilder
    func vibrantForeground(thick: Bool = false) -> some View {
        if #available(iOS 15, *) {
            foregroundStyle(thick ? .ultraThickMaterial : .bar)
        } else {
            foregroundColor(Color(.systemBackground))
        }
    }
}
