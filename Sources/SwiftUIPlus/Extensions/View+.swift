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
        _ condition: Bool,
        _ transform: (Self) -> T)
        -> some View where T: View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder @inlinable
    func `if`<T, _T>(
        _ condition: Bool,
        _ transform: (Self) -> T,
        else _transform: (Self) -> _T
    ) -> some View where T: View, _T: View {
        if condition {
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
@usableFromInline
struct Spacing: ViewModifier {
    @inlinable
    public init() { }
    @ViewBuilder @usableFromInline
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
        }
    }
}

extension Font {
    public static func system(
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

    public static func system(
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

public extension UIColor {
    fileprivate class func lightColor(withSeed seed: String) -> UIColor {
        srand48(seed.hash)

        let hue = CGFloat(drand48())
        let saturation = CGFloat(0.5)
        let brightness = CGFloat(1.0 - 0.25 * drand48())

        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }

    fileprivate class func darkColor(withSeed seed: String) -> UIColor {
        srand48(seed.hash)

        let hue = CGFloat(drand48())
        let saturation = CGFloat(0.5)
        let brightness = CGFloat(0.3 + 0.25 * drand48())

        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }

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

extension Binding {
    @inlinable
    func unwrapped<T>(_ defaultValue: T) -> Binding<T> where Value == Optional<T> {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}
