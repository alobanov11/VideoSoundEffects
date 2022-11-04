//
//  Created by Антон Лобанов on 03.11.2022.
//

import AVKit
import PhotosUI
import SwiftUI

struct ContentView: View {
	@AppStorage("isCameraAuthorized") private var isCameraAuthorized = false
	@AppStorage("isLibraryAuthorized") private var isLibraryAuthorized = false
	@AppStorage("isAudioAuthorized") private var isAudioAuthorized = false

	var body: some View {
		ZStack {
			if isCameraAuthorized && isLibraryAuthorized && isAudioAuthorized {
				NavigationStack {
					LibraryView()
				}
			}
			else {
				PermissionsView()
			}
		}
		.onAppear {
			isCameraAuthorized = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
			isLibraryAuthorized = PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized
			isAudioAuthorized = AVAudioSession.sharedInstance().recordPermission == .granted
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
