//
//  Shareable.swift
//
//
//  Created by Dmitry Mikhaylov on 16.05.2024.
//

import Foundation

#if os(macOS) || os(iOS)
    import SwiftUI

    @available(iOS, deprecated: 16.0)
    @available(macOS, deprecated: 13.0)
    @available(watchOS, deprecated: 9.0)

    /// TEMPORARY, DO NOT RELY ON THIS!
    ///
    /// - Note: This **will be removed** in an upcoming release, regardless of semantic versioning
    @available(iOS, message: "This **will be removed** in an upcoming release, regardless of semantic versioning")
    @available(macOS, message: "This **will be removed** in an upcoming release, regardless of semantic versioning")
    public protocol Shareable {
        var pathExtension: String { get }
        var itemProvider: NSItemProvider? { get }
    }

    internal struct ActivityItem<Data> where Data: RandomAccessCollection, Data.Element: Shareable {
        internal var data: Data
    }

    extension String: Shareable {
        public var pathExtensionTXT: String { "txt" }
        public var itemProvider: NSItemProvider? {
            do {
                let url = URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingPathComponent("\(UUID().uuidString)")
                    .appendingPathExtension(pathExtension)
                try write(to: url, atomically: true, encoding: .utf8)
                return .init(contentsOf: url)
            } catch {
                return nil
            }
        }
    }

    extension URL: Shareable {
        public var itemProvider: NSItemProvider? {
            .init(contentsOf: self)
        }
    }

    extension Image: Shareable {
        public var pathExtension: String { "jpg" }
        public var itemProvider: NSItemProvider? {
            do {
                let url = URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingPathComponent("\(UUID().uuidString)")
                    .appendingPathExtension(pathExtension)
                let renderer = ImageRenderer(content: self)

                #if os(iOS)
                    let data = renderer.uiImage?.jpegData(compressionQuality: 0.8)
                #else
                    let data = renderer.nsImage?.jpg(quality: 0.8)
                #endif

                try data?.write(to: url, options: .atomic)
                return .init(contentsOf: url)
            } catch {
                return nil
            }
        }
    }

    extension UIImage: Shareable {
        public var pathExtension: String { "jpg" }
        public var itemProvider: NSItemProvider? {
            do {
                let url = URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingPathComponent("\(UUID().uuidString)")
                    .appendingPathExtension(pathExtension)
                let data = jpg(quality: 0.8)
                try data?.write(to: url, options: .atomic)
                return .init(contentsOf: url)
            } catch {
                return nil
            }
        }
    }
#endif

#if os(macOS) || os(iOS)
    import SwiftUI

    @available(iOS, deprecated: 16.0)
    public struct ProposedViewSize: Equatable, Sendable {
        public var width: CGFloat?
        public var height: CGFloat?

        public static let zero = Self(width: 0, height: 0)
        public static let infinity = Self(width: .infinity, height: .infinity)
        public static let unspecified = Self(width: nil, height: nil)

        public init(_ size: CGSize) {
            self.width = size.width
            self.height = size.height
        }

        public init(width: CGFloat?, height: CGFloat?) {
            self.width = width
            self.height = height
        }

        public func replacingUnspecifiedDimensions(by size: CGSize) -> CGSize {
            .init(
                width: width ?? size.width,
                height: height ?? size.height
            )
        }
    }

    @available(iOS, deprecated: 16.0)
    public final class ImageRenderer<Content>: ObservableObject where Content: View {
        public var content: Content
        public var label: String?
        public var proposedSize: ProposedViewSize = .unspecified
        public var scale: CGFloat = UIScreen.mainScreen.scale
        public var isOpaque: Bool = false
        public var colorMode: ColorRenderingMode = .nonLinear

        public init(content: Content) {
            self.content = content
        }
    }

    public extension ImageRenderer {
        var cgImage: CGImage? {
            #if os(macOS)
                nsImage?.cgImage(forProposedRect: nil, context: .current, hints: nil)
            #else
                uiImage?.cgImage
            #endif
        }

        #if os(macOS)

            var nsImage: NSImage? {
                NSHostingController(rootView: content).view.snapshot
            }

        #else

            var uiImage: UIImage? {
                let controller = UIHostingController(rootView: content)
                let size = controller.view.intrinsicContentSize
                controller.view.bounds = CGRect(origin: .zero, size: size)
                controller.view.backgroundColor = .clear

                let format = UIGraphicsImageRendererFormat(for: controller.traitCollection)
                format.opaque = isOpaque
                format.scale = scale

                let renderer = UIGraphicsImageRenderer(size: size, format: format)

                let image = renderer.image { context in
                    controller.view.drawHierarchy(in: context.format.bounds, afterScreenUpdates: true)
                }

                image.accessibilityLabel = label
                objectWillChange.send()

                return image
            }

        #endif
    }

    #if os(iOS)
        extension ColorRenderingMode {
            var range: UIGraphicsImageRendererFormat.Range {
                switch self {
                case .extendedLinear: return .extended
                case .linear: return .standard
                default: return .automatic
                }
            }
        }
    #endif

    #if os(macOS)
        private extension NSView {
            var snapshot: NSImage? {
                return NSImage(data: dataWithPDF(inside: bounds))
            }
        }
    #endif
#endif
