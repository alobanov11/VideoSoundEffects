//
//  Created by Антон Лобанов on 04.11.2022.
//

import Foundation
import AVKit

final class PlayerLayerView: UIView {
	override static var layerClass: AnyClass { AVPlayerLayer.self }

	var player: AVPlayer? {
		get { playerLayer.player }
		set { playerLayer.player = newValue }
	}

	private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}
