//
//  Created by Антон Лобанов on 04.11.2022.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
	typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void

	let activityItems: [Any]
	let applicationActivities: [UIActivity]? = nil
	let excludedActivityTypes: [UIActivity.ActivityType]? = nil
	let callback: Callback? = nil

	func makeUIViewController(context _: Context) -> UIActivityViewController {
		let controller = UIActivityViewController(
			activityItems: self.activityItems,
			applicationActivities: self.applicationActivities
		)
		controller.excludedActivityTypes = self.excludedActivityTypes
		controller.completionWithItemsHandler = self.callback
		return controller
	}

	func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
