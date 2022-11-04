//
//  Created by Антон Лобанов on 04.11.2022.
//

import AVKit
import Foundation
import PhotosUI

final class CameraViewModel: NSObject, ObservableObject {
	let session = AVCaptureSession()

	@Published var error = false
	@Published var isRecording = false
	@Published var previewUrl: URL?

	private let videoOutput = AVCaptureMovieFileOutput()

	private let discoverySession = AVCaptureDevice.DiscoverySession(
		deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
		mediaType: .video,
		position: .unspecified
	)

	private let photoLibrary = PHPhotoLibrary.shared()

	func setUp() {
		guard
			let cameraDevice = self.discoverySession.devices.first(where: { $0.position == .back }),
			let audioDevice = AVCaptureDevice.default(for: .audio)
		else {
			return
		}
		onBackgroundThread { [weak self] in
			guard let self else { return }

			self.session.beginConfiguration()
			self.session.inputs.forEach { self.session.removeInput($0) }
			self.session.outputs.forEach { self.session.removeOutput($0) }

			do {
				let cameraInput = try AVCaptureDeviceInput(device: cameraDevice)
				let audioInput = try AVCaptureDeviceInput(device: audioDevice)

				if self.session.canAddInput(cameraInput), self.session.canAddInput(audioInput) {
					self.session.addInput(cameraInput)
					self.session.addInput(audioInput)
				}

				if self.session.canAddOutput(self.videoOutput) {
					self.session.addOutput(self.videoOutput)
				}
			}
			catch {
				self.error = true
				print(error)
			}

			self.session.commitConfiguration()
		}
	}

	func retake() {
		self.previewUrl = nil
		onBackgroundThread(self.session.startRunning)
	}

	func startRecordinng() {
		let tempFile = NSTemporaryDirectory() + "video.mov"
		self.isRecording = true
		self.videoOutput.startRecording(to: URL(fileURLWithPath: tempFile), recordingDelegate: self)
	}

	func stopRecording() {
		self.isRecording = false
		self.videoOutput.stopRecording()
		self.session.stopRunning()
	}

	func save(completion: @escaping (URL) -> Void) {
		guard let url = self.previewUrl else { return }
		self.photoLibrary.performChanges({
			PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
		}) { [weak self] _, error in
			if let error {
				self?.error = true
				print(error)
			}
			else {
				completion(url)
			}
		}
	}
}

extension CameraViewModel: AVCaptureFileOutputRecordingDelegate {
	func fileOutput(_: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from _: [AVCaptureConnection], error: Error?) {
		if let error {
			self.error = true
			print(error)
			return
		}
		self.previewUrl = outputFileURL
	}
}
