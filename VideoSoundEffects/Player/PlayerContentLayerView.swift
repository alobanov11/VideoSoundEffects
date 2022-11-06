//
//  Created by Антон Лобанов on 04.11.2022.
//
import AVKit
import Foundation

protocol IPlayerContentLayer: AnyObject {
    var player: AVPlayer? { get set }
}

final class PlayerContentLayerView: UIView, IPlayerContentLayer {
    override static var layerClass: AnyClass { AVPlayerLayer.self }

    var player: AVPlayer? {
        get { self.playerLayer.player }
        set {
            self.playerLayer.player = newValue
            self.playerLayer.videoGravity = .resizeAspectFill
            self.playerLayer.contentsGravity = .resizeAspectFill
        }
    }

    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}
