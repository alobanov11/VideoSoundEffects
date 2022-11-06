//
//  Created by Антон Лобанов on 04.11.2022.
//

import SwiftUI

extension CGFloat {
    static var screenFrame: CGRect {
        UIScreen.main.bounds
    }

    static var screenWidth: CGFloat {
        self.screenFrame.width
    }

    static var screenHeight: CGFloat {
        self.screenFrame.height
    }
}
