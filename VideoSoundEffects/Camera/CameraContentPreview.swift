//
//  Created by Антон Лобанов on 04.11.2022.
//

import AVKit
import SwiftUI

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
        .preferredColorScheme(.dark)
    }
}

struct AVPlayerControllerRepresented: UIViewControllerRepresentable {
    var player: AVPlayer

    func makeUIViewController(context _: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = self.player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        return controller
    }

    func updateUIViewController(_: AVPlayerViewController, context _: Context) {}
}
