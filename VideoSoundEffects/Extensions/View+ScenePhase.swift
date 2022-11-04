//
//  Created by Антон Лобанов on 04.11.2022.
//

import SwiftUI

extension View {
	func onBackground(_ f: @escaping () -> Void) -> some View {
		self.onReceive(
			NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
			perform: { _ in f() }
		)
	}

	func onForeground(_ f: @escaping () -> Void) -> some View {
		self.onReceive(
			NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification),
			perform: { _ in f() }
		)
	}
}
