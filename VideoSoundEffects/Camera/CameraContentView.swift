//
//  Created by Антон Лобанов on 04.11.2022.
//

import SwiftUI

protocol ICameraContentLayerConfigurator {
    func configureLayer(_ layer: ICameraContentLayer)
}

struct CameraContentView: UIViewRepresentable {
    let configurator: ICameraContentLayerConfigurator

    func makeUIView(context _: Context) -> UIView {
        let view = CameraContentLayerView()

        self.configurator.configureLayer(view)

        return view
    }

    func updateUIView(_: UIView, context _: Context) {}
}
