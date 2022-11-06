//
//  Created by Антон Лобанов on 03.11.2022.
//
import SwiftUI

protocol IPlayerContentLayerConfigurator {
    func configureLayer(_ layer: IPlayerContentLayer)
}

struct PlayerContentView: UIViewRepresentable {
    let configurator: IPlayerContentLayerConfigurator

    func makeUIView(context _: Context) -> PlayerContentLayerView {
        let view = PlayerContentLayerView()

        self.configurator.configureLayer(view)

        view.layer.cornerRadius = 36
        view.clipsToBounds = true

        return view
    }

    func updateUIView(_: PlayerContentLayerView, context _: Context) {}
}
