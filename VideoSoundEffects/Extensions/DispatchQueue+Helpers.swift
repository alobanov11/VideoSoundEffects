//
//  Created by Антон Лобанов on 04.11.2022.
//

import Foundation

public func onMainThread(_ block: @escaping () -> Void) {
	if Thread.isMainThread {
		block()
	}
	else {
		DispatchQueue.main.async(execute: block)
	}
}

public func onMainThreadAsync(_ block: @escaping () -> Void) {
	DispatchQueue.main.async(execute: block)
}

public func onBackgroundThread(_ block: @escaping () -> Void) {
	onBackgroundThread(qos: .default)(block)
}

public func onBackgroundThread(qos: DispatchQoS.QoSClass) -> (@escaping () -> Void) -> Void {
	{
		DispatchQueue.global(qos: qos).async(execute: $0)
	}
}
