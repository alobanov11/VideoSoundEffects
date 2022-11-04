//
//  Created by Антон Лобанов on 04.11.2022.
//

import SwiftUI
import AVFoundation

struct CameraContentView: UIViewRepresentable {
	@ObservedObject var viewModel: CameraViewModel

	func makeUIView(context: Context) -> UIView {
		let view = UIView(frame: CGFloat.screenFrame)
		let layer = AVCaptureVideoPreviewLayer(session: self.viewModel.session)

		layer.frame = view.frame
		layer.videoGravity = .resizeAspectFill
		view.layer.addSublayer(layer)

		onBackgroundThread {
			viewModel.session.startRunning()
		}

		return view
	}

	func updateUIView(_ uiView: UIView, context: Context) {}
}
