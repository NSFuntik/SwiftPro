//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 27.02.2024.
//

import SwiftUI

public enum ColorError: Error {
    case invalidHexString
    case invalidScanHexInt64
    case invalidHexDigitInIntegerLiteral
    var localizedDescrioprion: LocalizedStringKey {
        return switch self {
        case .invalidHexString: "Invalid hexadecimal value"
        case .invalidScanHexInt64: "Valid hexadecimal long long representation wasn't found"
        case .invalidHexDigitInIntegerLiteral: "Invalid hex digit in Integer literal "
        }
    }
}

/// Provides a `projectedValue` that returns a SwiftUI `Color` based on the color
/// hex code of the wrapped value (or `nil` if the hex string is invalid).
@propertyWrapper public struct HexColor: Codable {
    public var wrappedValue: String

    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }

    public var projectedValue: Color {
        if let c = try? Color(hex: wrappedValue) {
            return c
        } else {
            return Color(uiColor: UIColor(ciColor: CIColor(string: self.wrappedValue)))
        }
    }
}

extension Color {
    init?(hex: String) throws {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        let a, r, g, b: UInt64

        guard Scanner(string: hexSanitized)
            .scanHexInt64(&rgb) else { throw ColorError.invalidScanHexInt64 }

        switch hexSanitized.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (rgb >> 8) * 17, (rgb >> 4 & 0xF) * 17, (rgb & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, rgb >> 16, rgb >> 8 & 0xFF, rgb & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (rgb >> 24, rgb >> 16 & 0xFF, rgb >> 8 & 0xFF, rgb & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
            throw ColorError.invalidHexDigitInIntegerLiteral
        }

        self.init(.displayP3,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    public var color: Color {
        Color(uiColor: self)
    }
}
