//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 12.03.2024.
//

import AVFoundation
import UIKit
import SwiftUI

public extension UIImage.Orientation {
    init(_ cgOrientation: CGImagePropertyOrientation) {
        switch cgOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

public extension Image {
    
    /// This is a shorthand for `Image(systemName:)`.
    static func system(_ name: String) -> Image {
        .init(systemName: name)
    }
}
public extension UIImage {
    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func scaleToFill(in targetSize: CGSize) -> UIImage {
        guard targetSize != .zero else {
            return self
        }

        let image = self
        let imageBounds = CGRect(origin: .zero, size: size)
        let cropRect = AVMakeRect(aspectRatio: targetSize, insideRect: imageBounds)
        let rendererFormat = UIGraphicsImageRendererFormat(); rendererFormat.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: rendererFormat)
        return renderer.image { context in
            // UIImage and CGContext coordinates are flipped.
            var transform = CGAffineTransform(translationX: 0.0, y: targetSize.height)
            transform = transform.scaledBy(x: 1, y: -1)
            context.cgContext.concatenate(transform)

            if let cgImage = image.cgImage?.cropping(to: cropRect) {
                context.cgContext.draw(cgImage, in: CGRect(origin: .zero, size: targetSize))
            } // TODO: CIImage
        }
    }

    /// Create image with proper orientation
    convenience init?(photo: AVFoundation.AVCapturePhoto) {
        guard let cgImage = photo.cgImageRepresentation(),
              let rawOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
              let cgOrientation = CGImagePropertyOrientation(rawValue: rawOrientation) else {
            return nil
        }

        let imageOrientation = UIImage.Orientation(cgOrientation)
        self.init(cgImage: cgImage, scale: 1, orientation: imageOrientation)
    }

    // MARK: - UIImage+Resize

    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }

    var png: Data? { pngData() }
    func jpg(quality: CGFloat) -> Data? { jpegData(compressionQuality: quality) }
}
