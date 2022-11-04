//
//  Created by Антон Лобанов on 04.11.2022.
//

import AVFoundation
import SwiftUI

struct CameraContentView: UIViewRepresentable {
	@ObservedObject var viewModel: CameraViewModel

	func makeUIView(context _: Context) -> UIView {
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

	func updateUIView(_: UIView, context _: Context) {}
}
