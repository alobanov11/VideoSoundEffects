//
//  Created by Антон Лобанов on 03.11.2022.
//

import PhotosUI
import SwiftUI

final class VideoViewModel: ObservableObject, Identifiable {
    let duration: TimeInterval

    @Published var image: UIImage?

    private let imageManager = PHImageManager.default()
    private let asset: PHAsset

    init(asset: PHAsset) {
        self.duration = asset.duration
        self.asset = asset
    }

    func requestImage() {
        self.imageManager.requestImage(
            for: self.asset,
            targetSize: CGSize(width: .screenWidth * 0.5, height: .screenHeight * 0.3),
            contentMode: .aspectFill,
            options: nil
        ) { [weak self] image, _ in
            self?.image = image
        }
    }

    func requestAVAsset(completion: @escaping (AVAsset?) -> Void) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        self.imageManager.requestAVAsset(
            forVideo: self.asset,
            options: options
        ) { asset, _, _ in
            onMainThread {
                completion(asset)
            }
        }
    }
}

extension VideoViewModel: Hashable {
    static func == (lhs: VideoViewModel, rhs: VideoViewModel) -> Bool {
        lhs.asset == rhs.asset
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.asset)
    }
}
