//
//  Created by Антон Лобанов on 03.11.2022.
//

import AVFoundation
import PhotosUI
import SwiftUI

struct PermissionsView: View {
    @AppStorage("isCameraAuthorized") var isCameraAuthorized = false
    @AppStorage("isLibraryAuthorized") var isLibraryAuthorized = false
    @AppStorage("isAudioAuthorized") var isAudioAuthorized = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Before we start")
                .multilineTextAlignment(.center)
                .font(.system(.largeTitle, design: .monospaced))

            Text("We need some permissions:")
                .lineSpacing(9.0)
                .multilineTextAlignment(.center)
                .font(.system(.body, design: .monospaced))

            VStack {
                HStack(spacing: 12) {
                    Button(action: requestCameraPermission) {
                        HStack {
                            Text("Camera")
                                .foregroundColor(.white)
                                .font(.system(.body, design: .monospaced))
                            if isCameraAuthorized {
                                Image(systemName: "checkmark.circle.fill")
                                    .tint(.white)
                            }
                        }
                        .padding()
                        .background(Capsule().fill(Color.accentColor))
                    }

                    Button(action: requestLibraryPermission) {
                        HStack {
                            Text("Library")
                                .foregroundColor(.white)
                                .font(.system(.body, design: .monospaced))
                            if isLibraryAuthorized {
                                Image(systemName: "checkmark.circle.fill")
                                    .tint(.white)
                            }
                        }
                        .padding()
                        .background(Capsule().fill(Color.accentColor))
                    }
                }

                Button(action: requestAudioPermission) {
                    HStack {
                        Text("Audio")
                            .foregroundColor(.white)
                            .font(.system(.body, design: .monospaced))
                        if isAudioAuthorized {
                            Image(systemName: "checkmark.circle.fill")
                                .tint(.white)
                        }
                    }
                    .padding()
                    .background(Capsule().fill(Color.accentColor))
                }
            }

            Spacer()

            Button(action: goToSettings) {
                Text("Go to settings")
            }
            .padding(.bottom)
        }
        .padding(.horizontal, 48)
    }
}

private extension PermissionsView {
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { isCameraAuthorized = $0 }
    }

    func requestLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { isLibraryAuthorized = $0 == .authorized }
    }

    func requestAudioPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission {
            isAudioAuthorized = $0
        }
    }

    func goToSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }
}

struct PermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsView()
    }
}
