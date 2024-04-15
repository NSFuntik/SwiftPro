//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 16.04.2024.
//

import UIKit

public enum DataUnits: String {
   case byte, kilobyte, megabyte, gigabyte
    public typealias Value = Double
    public var bytes: Value {
        switch self {
        case .byte:
            1
        case .kilobyte:
            1024
        case .megabyte:
            1024 * 1024
        case .gigabyte:
            1024 * 1024 * 1024
        }
    }

    public typealias Unit = (size: Double, unit: Self)

    public static func getInBytes(from unit: Unit) -> Value {
        return unit.size * unit.unit.bytes
    }
}

public extension UIImage {
    func getSizeString(in units: DataUnits) -> String {
        return String(format: "%.2f", getSizeValue(in: units))
    }
    
    func getSizeValue(in type: DataUnits) -> Double {
        guard let data = jpegData(compressionQuality: 1.0) else {
            return 0
        }
        var size: Double = 0.0
        switch type {
        case .byte:
            size = Double(data.count)
        case .kilobyte:
            size = Double(data.count) / 1024
        case .megabyte:
            size = Double(data.count) / 1024 / 1024
        case .gigabyte:
            size = Double(data.count) / 1024 / 1024 / 1024
        }
        return size
    }

}

public extension UInt64 {
    func getSizeIn(_ type: DataUnits) -> String {
        var size: Double = 0.0
        switch type {
        case .byte:
            size = Double(self)
        case .kilobyte:
            size = Double(self) / 1024
        case .megabyte:
            size = Double(self) / 1024 / 1024
        case .gigabyte:
            size = Double(self) / 1024 / 1024 / 1024
        }
        return String(format: "%.0f", size)
    }
}
