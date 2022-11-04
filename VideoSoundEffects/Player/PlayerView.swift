//
//  Created by Антон Лобанов on 03.11.2022.
//

import SwiftUI
import AVKit

struct PlayerView: UIViewRepresentable {
	@ObservedObject var viewModel: PlayerViewModel

	func makeUIView(context: Context) -> PlayerLayerView {
		let view = PlayerLayerView()
		view.player = self.viewModel.player
		return view
	}

	func updateUIView(_ uiView: PlayerLayerView, context: Context) { }
}
