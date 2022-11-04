//
//  Created by Антон Лобанов on 04.11.2022.
//

import AVKit
import Foundation

final class PlayerLayerView: UIView {
	override static var layerClass: AnyClass { AVPlayerLayer.self }

	var player: AVPlayer? {
		get { self.playerLayer.player }
		set { self.playerLayer.player = newValue }
	}

	private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}
