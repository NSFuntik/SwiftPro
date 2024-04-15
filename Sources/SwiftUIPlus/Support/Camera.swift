//
//  Camera.swift
//
//
//  Created by Dmitry Mikhaylov on 01.03.2024.
//

import AVFoundation
import CoreImage
import Photos
import SwiftUI
import UIKit
extension UIImage: Identifiable {
    public var id: Int {
        return hashValue
    }
}

#Preview {
    CameraView(.constant(UIImage()))
}

public struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var camera: Camera = Camera()
    @State var viewfinderImage: Image? = nil
    @Binding var outputImage: UIImage?
    @State var capturedImage: UIImage? = nil
    @State private var authorizationStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @State private var outputSize: CGSize = .zero
    
    private var options: CameraViewOptions = CameraViewOptions()
    private let barHeightFactor = 0.15
    public init(_ outputImage: Binding<UIImage?>) {
        _outputImage = outputImage
    }
        //    @State private var showsTakePictureFeedback: Bool = false
    
    public var body: some View {
        GeometryReader { geometry in
            ViewfinderView(image: $viewfinderImage)
            //                           showsTakePictureFeedback: $showsTakePictureFeedback)
            
                .overlay(alignment: .bottom) {
                    buttonsView()
                        .frame(height: geometry.size.height * self.barHeightFactor)
                        .materialBackground()
                }
        }
        .environment(\.takePicture, TakePictureAction {
            //            showsTakePictureFeedback = true
            
            guard let capturedPhoto = try? await camera.takePhoto(),
                  let image = UIImage(photo: capturedPhoto)
                    
            else { return }
            //            if image.getSizeIn(.megabyte) > 4.9 {
            //                Log.global.error("Image is too large \(image.getSizeIn(.megabyte))")
            //                guard let compressedImage = try? image.compress()
            //                else {
            //                    Log.global.error("Can't compress image")
            //                    return
            //                }
            //                image = compressedImage
            //            }
            capturedImage = image
            if let capturedImage {
                withAnimation {
                    viewfinderImage = Image(uiImage: capturedImage)
                }
            }
            
        })
        .ignoresSafeArea()
        .statusBar(hidden: true)
        .task {
#if targetEnvironment(simulator) && SWIFT_PACKAGE
            viewfinderImage = .init("CaptureTemp", bundle: .module)
#else
            await handleCameraPreviews()
#endif
        }
    }
    
    @ViewBuilder
    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Label("Close Camera", systemImage: "xmark")
                    .font(.system(size: 36, weight: .medium))
                    .background(Circle().fill(Color.secondary.opacity(0.33)).frame(box: 55))
            }
            
            if capturedImage != nil {
                Button {
                    withAnimation {
                        outputImage = capturedImage
                    }
                } label: {
                    Label {
                        Text("Send Photo")
                    } icon: {
                        let color = (try? Color(hex: "#4676DA")) ?? Color(.systemBlue)
                        ZStack {
                            Circle()
                                .fill(color.opacity(0.88)).clipShape(Circle())
                                .frame(box: 77)
                            
                            Image(systemName: "paperplane.fill").symbolVariant(.slash)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.88))
                                .rotationEffect(.degrees(45), anchor: .center)
                                .offset(x: -3).shadow(color: .secondary, radius: 3, x: -3, y: 0)
                        }
                    }
                }
            } else {
                Button {
                    Task { @MainActor in
                        do {
                            //                            $showsTakePictureFeedback.wrappedValue = true
                            let capturePhoto = try await camera.takePhoto()
                            
                            withFeedback(
                                .flash(Color.white.opacity(0.88), duration: 0.1488)
                                .combined(with: .haptic(.impact))
                            ) {
                                camera.stop()
                            }
                            let image = UIImage(photo: capturePhoto)
                            capturedImage = image?.fixOrientation().scaleToFill(in: outputSize)
                        } catch {
                            capturedImage = nil
                            throw error
                        }
                    }
                } label: {
                    Label {
                        Text("Take Photo")
                    } icon: {
                        ZStack {
                            Circle()
                                .strokeBorder(.white.opacity(0.88), lineWidth: 4)
                                .frame(box: 77)
                            Circle()
                                .fill(.white.opacity(0.66))
                                .frame(box: 63)
                        }
                    }
                }
            }
            
            Button {
                if capturedImage != nil {
                    capturedImage = nil
                    Task { @MainActor in
                        await camera.start()
                    }
                } else {
                    camera.switchCaptureDevice()
                }
            } label: {
                Label("Switch Camera", systemImage: capturedImage == nil ? "arrow.triangle.2.circlepath" : "repeat")
                    .font(.system(size: 36, weight: .medium))
                    .background(Circle().fill(Color.secondary.opacity(0.33)).frame(box: 55))
            }
            
            Spacer()
        }
        .foregroundStyle(.white.opacity(0.66))
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
        .animation(.bouncy, value: capturedImage)
    }
    
    func handleCameraPreviews() async {
        await camera.start()
        
        let imageStream = camera.previewStream
            .map { $0.image }
        
        for await image in imageStream {
            Task { @MainActor in
                viewfinderImage = image
            }
        }
    }
    
    struct ViewfinderView: View {
        @Binding var image: Image?
        //        @Binding var showsTakePictureFeedback: Bool
        var body: some View {
            GeometryReader { geometry in
                if let image = image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
    }
    
    public struct CameraViewOptions {
        public private(set) static var `default` = CameraViewOptions()
        var automaticallyRequestAuthorization: Bool = true
        var isTakePictureFeedbackEnabled: Bool = true
    }
}

class Camera: NSObject, ObservableObject {
    private let captureSession = AVCaptureSession()
    private var isCaptureSessionConfigured = false
    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var sessionQueue: DispatchQueue!
    private var didTakePicture: ((Result<AVCapturePhoto, Error>) -> Void)?
    
    private var allCaptureDevices: [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera, .builtInDualWideCamera], mediaType: .video, position: .unspecified).devices
    }
    
    private var frontCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices
            .filter { $0.position == .front }
    }
    
    private var backCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices
            .filter { $0.position == .back }
    }
    
    private var captureDevices: [AVCaptureDevice] {
        var devices = [AVCaptureDevice]()
#if os(macOS) || (os(iOS) && targetEnvironment(macCatalyst))
        devices += allCaptureDevices
#else
        if let backDevice = backCaptureDevices.first {
            devices += [backDevice]
        }
        if let frontDevice = frontCaptureDevices.first {
            devices += [frontDevice]
        }
#endif
        return devices
    }
    
    private var availableCaptureDevices: [AVCaptureDevice] {
        captureDevices
            .filter({ $0.isConnected })
            .filter({ !$0.isSuspended })
    }
    
    private var captureDevice: AVCaptureDevice? {
        didSet {
            guard let captureDevice = captureDevice else { return }
            debugPrint("Using capture device: \(captureDevice.localizedName)")
            sessionQueue.async {
                self.updateSessionForCaptureDevice(captureDevice)
            }
        }
    }
    
    var isRunning: Bool {
        captureSession.isRunning
    }
    
    var isUsingFrontCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return frontCaptureDevices.contains(captureDevice)
    }
    
    var isUsingBackCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return backCaptureDevices.contains(captureDevice)
    }
    
    private var addToPhotoStream: ((AVCapturePhoto) -> Void)?
    
    private var addToPreviewStream: ((CIImage) -> Void)?
    
    var isPreviewPaused = false
    
    lazy var previewStream: AsyncStream<CIImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { ciImage in
                if !self.isPreviewPaused {
                    continuation.yield(ciImage)
                }
            }
        }
    }()
    
    lazy var photoStream: AsyncStream<AVCapturePhoto> = {
        AsyncStream { continuation in
            addToPhotoStream = { photo in
                continuation.yield(photo)
            }
        }
    }()
    
    override init() {
        super.init()
        initialize()
    }
    
    private func initialize() {
        sessionQueue = DispatchQueue(label: "session queue")
        
        captureDevice = availableCaptureDevices.first ?? AVCaptureDevice.default(for: .video)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }
    
    private func configureCaptureSession(completionHandler: (_ success: Bool) -> Void) {
        var success = false
        
        captureSession.beginConfiguration()
        
        defer {
            self.captureSession.commitConfiguration()
            completionHandler(success)
        }
        
        guard
            let captureDevice = captureDevice,
            let deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        else {
            debugPrint("Failed to obtain video input.")
            return
        }
        
        let photoOutput = AVCapturePhotoOutput()
        
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoDataOutputQueue"))
        
        guard captureSession.canAddInput(deviceInput) else {
            debugPrint("Unable to add device input to capture session.")
            return
        }
        guard captureSession.canAddOutput(photoOutput) else {
            debugPrint("Unable to add photo output to capture session.")
            return
        }
        guard captureSession.canAddOutput(videoOutput) else {
            debugPrint("Unable to add video output to capture session.")
            return
        }
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)
        
        self.deviceInput = deviceInput
        self.photoOutput = photoOutput
        self.videoOutput = videoOutput
        
        photoOutput.isHighResolutionCaptureEnabled = false
        photoOutput.maxPhotoQualityPrioritization = .speed
        
        updateVideoOutputConnection()
        
        isCaptureSessionConfigured = true
        
        success = true
    }
    
    private func checkAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            debugPrint("Camera access authorized.")
            return true
        case .notDetermined:
            debugPrint("Camera access not determined.")
            sessionQueue.suspend()
            let status = await AVCaptureDevice.requestAccess(for: .video)
            sessionQueue.resume()
            return status
        case .denied:
            debugPrint("Camera access denied.")
            return false
        case .restricted:
            debugPrint("Camera library access restricted.")
            return false
        @unknown default:
            return false
        }
    }
    
    private func deviceInputFor(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch let error {
            debugPrint("Error getting capture device input: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
        guard isCaptureSessionConfigured else { return }
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        defer { captureSession.commitConfiguration() }
        
        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(deviceInput)
            }
        }
        
        if let deviceInput = deviceInputFor(device: captureDevice) {
            if !captureSession.inputs.contains(deviceInput), captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }
        }
        
        updateVideoOutputConnection()
    }
    
    private func updateVideoOutputConnection() {
        if let videoOutput = videoOutput, let videoOutputConnection = videoOutput.connection(with: .video) {
            if videoOutputConnection.isVideoMirroringSupported {
                videoOutputConnection.isVideoMirrored = isUsingFrontCaptureDevice
            }
        }
    }
    
    func start() async {
        let authorized = await checkAuthorization()
        guard authorized else {
            debugPrint("Camera access was not authorized.")
            return
        }
        
        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                sessionQueue.async { [self] in
                    self.captureSession.startRunning()
                }
            }
            return
        }
        
        sessionQueue.async { [self] in
            self.configureCaptureSession { success in
                guard success else { return }
                self.captureSession.startRunning()
            }
        }
    }
    
    func stop() {
        guard isCaptureSessionConfigured else { return }
        
        if captureSession.isRunning {
            sessionQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func switchCaptureDevice() {
        if let captureDevice = captureDevice, let index = availableCaptureDevices.firstIndex(of: captureDevice) {
            let nextIndex = (index + 1) % availableCaptureDevices.count
            self.captureDevice = availableCaptureDevices[nextIndex]
        } else {
            captureDevice = AVCaptureDevice.default(for: .video)
        }
    }
    
    private var deviceOrientation: UIDeviceOrientation {
        var orientation = UIDevice.current.orientation
        if orientation == UIDeviceOrientation.unknown {
            orientation = UIScreen.orientation
        }
        return orientation
    }
    
    private func videoOrientationFor(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation? {
        switch deviceOrientation {
        case .portrait: return AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown: return AVCaptureVideoOrientation.portraitUpsideDown
        case .landscapeLeft: return AVCaptureVideoOrientation.landscapeRight
        case .landscapeRight: return AVCaptureVideoOrientation.landscapeLeft
        default: return nil
        }
    }
    
    func takePhoto() async throws -> AVCapturePhoto {
        guard let photoOutput = photoOutput else { throw CameraError.missingPhotoOutput }
        defer { didTakePicture = nil }
        
        return try await withCheckedThrowingContinuation { continuation in
            didTakePicture = { continuation.resume(with: $0) }
            sessionQueue.async {
                let photoSettings = photoOutput.photoSettings()
                photoOutput.capturePhoto(with: photoSettings, delegate: self)
            }
        }
    }
}

public enum CameraError: Error {
    case missingPhotoOutput, missingVideoOutput
}

extension Camera: AVCapturePhotoCaptureDelegate {
    public func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            didTakePicture?(.failure(error))
        } else {
            didTakePicture?(.success(photo))
        }
    }
}

struct PhotoData {
    var thumbnailImage: Image
    var thumbnailSize: (width: Int, height: Int)
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}

extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
        
        if connection.isVideoOrientationSupported,
           let videoOrientation = videoOrientationFor(deviceOrientation) {
            connection.videoOrientation = videoOrientation
        }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        addToPreviewStream?(ciImage)
    }
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: extent) else { return nil }
        
        return Image(decorative: cgImage, scale: 0.5, orientation: .up)
    }
}

fileprivate extension Image.Orientation {
    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
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

public struct TakePictureAction {
    var handler: () async -> Void = {
        assertionFailure("@Environment(\\.takePicture) must be accessed from a camera overlay view")
    }
    
    public func callAsFunction() {
        Task { await handler() }
    }
}

private enum TakePictureEnvironmentKey: EnvironmentKey {
    static var defaultValue: TakePictureAction = .init()
}

extension EnvironmentValues {
    public internal(set) var takePicture: TakePictureAction {
        get { self[TakePictureEnvironmentKey.self] }
        set { self[TakePictureEnvironmentKey.self] = newValue }
    }
}

extension AVCapturePhotoOutput {
    func photoSettings() -> AVCapturePhotoSettings {
        let photoSettings: AVCapturePhotoSettings
        
        if availablePhotoCodecTypes.contains(.jpeg) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        } else {
            photoSettings = AVCapturePhotoSettings()
            photoSettings.isHighResolutionPhotoEnabled = false
        }
        
        photoSettings.photoQualityPrioritization = .speed
        if let pixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [
                String(kCVPixelBufferPixelFormatTypeKey): pixelFormatType,
            ]
        }
        return photoSettings
    }
}