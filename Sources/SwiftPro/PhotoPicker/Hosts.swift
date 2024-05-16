
import Photos
import PhotosUI
import SwiftUI
import UIKit
import CoreServices
public struct PHPickerAsset: Identifiable, Hashable {
   public var id: String
    var image: UIImage
    var url: URL
    var name: String
    var size: String
}
public extension NSItemProvider {
    func loadObject<T>(of type: T.Type) async throws -> T where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
        try await withCheckedThrowingContinuation { continuation in
            _ = loadObject(ofClass: T.self) { (value: _ObjectiveCBridgeable?, error: Error?) in
                switch (value, error) {
                case let (.some(value as T), nil):
                    continuation.resume(returning: value)
                case let (_, .some(error)):
                    continuation.resume(throwing: error)
                    return
                default:
                    return
                }
            }
        }
    }
}

extension NSData: NSItemProviderReading {
    public static var readableTypeIdentifiersForItemProvider: [String] { [String(UTType.data.identifier)] }
    public static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self { NSData(data: data) as! Self }
}
extension PHPickerResult: Identifiable {
    public var id: Int {
        hashValue
    }

    public func image() async throws -> UIImage {
        if let data = try await loadTransfer(_type: Data.self),
           let imageFull = UIImage(data: data) {
            do {
                let compressedData = try data.compress()
                guard let uiImage = UIImage(data: compressedData)
                else { throw CompressionError.initError }
                debugPrint("Compressed \(imageFull.getSizeString(in: .byte)) to \(uiImage.getSizeString(in: .byte)) bytes")
                return uiImage
            } catch {
                debugPrint("Failed to compress image  error: \(error).")
                throw CompressionError.processError
            }
        } else {
            throw CompressionError.initError
        }
    }

    public func fileAttributes() async throws -> (String, String) {
        var fileAttributes: (String, String) = ("", "")

        fileAttributes = try await withCheckedThrowingContinuation { continuation in
            self.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.item") { url, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    if let url = url {
                        continuation.resume(returning: (itemProvider.suggestedName ?? url.lastPathComponent, url.fileSizeString ?? ""))
                    } else {
                        continuation.resume(returning: (itemProvider.suggestedName ?? "", ""))
                    }
                }
            }
        }

        return fileAttributes
    }
}

public extension View {
    @ViewBuilder
    func _photoPicker(
        isPresented: Binding<Bool>,
        selection: Binding<[PHPickerResult]>,
        filter: PHPickerFilter?,
        maxSelectionCount: Int?,
        preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode,
        library: PHPhotoLibrary
    ) -> some View {
        sheet(isPresented: isPresented) {
            PhotosViewController(
                isPresented: isPresented,
                selection: selection,
                filter: filter,
                maxSelectionCount: maxSelectionCount,
                preferredAssetRepresentationMode: preferredAssetRepresentationMode,
                library: library
            )
            .ignoresSafeArea()
        }
    }
}

fileprivate struct PhotosViewController: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selection: [PHPickerResult]
    let configuration: PHPickerConfiguration

    init(isPresented: Binding<Bool>,
         selection: Binding<[PHPickerResult]>,
         filter: PHPickerFilter?,
         maxSelectionCount: Int?,
         preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode,
         library: PHPhotoLibrary) {
        _isPresented = isPresented
        _selection = selection

        var configuration = PHPickerConfiguration(photoLibrary: library)
        configuration.preferredAssetRepresentationMode = preferredAssetRepresentationMode
        configuration.selectionLimit = maxSelectionCount ?? 0
        configuration.filter = filter
        self.configuration = configuration
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, selection: $selection, configuration: configuration)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        context.coordinator.controller
    }

    func updateUIViewController(_ controller: UIViewController, context: Context) {
        context.coordinator.isPresented = $isPresented
        context.coordinator.selection = $selection
        context.coordinator.configuration = configuration
    }
}

fileprivate extension PhotosViewController {
    final class Coordinator: NSObject, PHPickerViewControllerDelegate, UIAdaptivePresentationControllerDelegate {
        var isPresented: Binding<Bool>
        var selection: Binding<[PHPickerResult]>
        var configuration: PHPickerConfiguration

        lazy var controller: PHPickerViewController = {
            let controller = PHPickerViewController(configuration: configuration)
            controller.presentationController?.delegate = self
            controller.delegate = self
            return controller
        }()

        init(isPresented: Binding<Bool>, selection: Binding<[PHPickerResult]>, configuration: PHPickerConfiguration) {
            self.isPresented = isPresented
            self.selection = selection
            self.configuration = configuration
            super.init()
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            isPresented.wrappedValue = false
            selection.wrappedValue = results
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            isPresented.wrappedValue = false
        }
    }
}
