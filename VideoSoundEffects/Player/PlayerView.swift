//
//  Created by Антон Лобанов on 03.11.2022.
//

import AVKit
import SwiftUI

struct PlayerView: UIViewRepresentable {
	@ObservedObject var viewModel: PlayerViewModel

	func makeUIView(context _: Context) -> PlayerLayerView {
		let view = PlayerLayerView()
		view.player = self.viewModel.player
		return view
	}

	func updateUIView(_: PlayerLayerView, context _: Context) {}
}
