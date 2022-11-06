//
//  Created by Антон Лобанов on 04.11.2022.
//
import AVFoundation
import SwiftUI

protocol ICameraContentLayer: AnyObject {
    var session: AVCaptureSession? { get set }
}

final class CameraContentLayerView: UIView, ICameraContentLayer {
    override static var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    var session: AVCaptureSession? {
        get { self.previewLayer.session }
        set {
            self.previewLayer.session = newValue
            self.previewLayer.videoGravity = .resizeAspectFill
            self.previewLayer.contentsGravity = .resizeAspectFill
        }
    }

    private var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}
