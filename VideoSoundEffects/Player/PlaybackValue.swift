//
//  Created by Антон Лобанов on 03.11.2022.
//

import Foundation

struct PlaybackValue: Identifiable {
    let value: Double
    let label: String

    var id: String {
        "\(self.label)-\(self.value)"
    }
}
