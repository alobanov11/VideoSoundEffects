//
//  Created by Антон Лобанов on 04.11.2022.
//

import SwiftUI
import AVKit

struct CameraContentPreview: View {
	let url: URL

	var body: some View {
		ZStack {
			let player = AVPlayer(url: url)
			AVPlayerControllerRepresented(player: player)
				.onAppear {
					player.play()
				}
				.onDisappear {
					player.pause()
				}
		}
		.background(Color.black)
	}
}


struct AVPlayerControllerRepresented : UIViewControllerRepresentable {
	var player : AVPlayer

	func makeUIViewController(context: Context) -> AVPlayerViewController {
		let controller = AVPlayerViewController()
		controller.player = player
		controller.showsPlaybackControls = false
		return controller
	}

	func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
