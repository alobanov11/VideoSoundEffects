//
//  Created by Антон Лобанов on 03.11.2022.
//

import SwiftUI

struct CameraView: View {
	let onFinish: (URL) -> Void

	@Environment(\.dismiss) private var dismiss
	@Environment(\.scenePhase) var scenePhase
	@StateObject private var viewModel = CameraViewModel()

	var body: some View {
		ZStack {
			CameraContentView(viewModel: viewModel)
				.ignoresSafeArea()

			if let url = viewModel.previewUrl {
				CameraContentPreview(url: url)
					.ignoresSafeArea()
			}

			VStack {
				if viewModel.previewUrl != nil {
					HStack {
						Button(action: viewModel.retake) {
							Image(systemName: "chevron.backward")
								.foregroundColor(.white)
								.padding()
								.background(Color.accentColor)
								.clipShape(Circle())
						}
						.padding(.leading)

						Spacer()
					}
					.padding(.top)
				}

				if viewModel.previewUrl == nil {
					HStack {
						Button(action: dismiss.callAsFunction) {
							Image(systemName: "xmark")
								.foregroundColor(.white)
								.padding()
								.background(Color.accentColor)
								.clipShape(Circle())
						}
						.padding(.leading)

						Spacer()
					}
					.padding(.top)
				}

				Spacer()

				HStack {
					if viewModel.previewUrl != nil {
						Spacer()

						Button(action: done) {
							Text("Done")
								.foregroundColor(.white)
								.font(.system(.body, design: .monospaced))
								.kerning(0.12)
								.padding(.vertical, 10)
								.padding(.horizontal, 20)
								.background(Color.accentColor)
								.clipShape(Capsule())
						}
						.padding(.trailing)
					}
					else {
						Button(action: process) {
							ZStack {
								Circle()
									.fill(viewModel.isRecording ? Color.accentColor : Color.white)
									.frame(width: 75, height: 75)

								Circle()
									.stroke(viewModel.isRecording ? Color.accentColor : Color.white, lineWidth: 2)
									.frame(width: 85, height: 85)
							}
						}
					}
				}
				.frame(height: 75)
				.padding(.bottom)
			}
		}
		.preferredColorScheme(.dark)
		.alert(isPresented: $viewModel.error) {
			Alert(title: Text("Something went wrong😵"), dismissButton: .cancel(dismiss.callAsFunction))
		}
		.onAppear(perform: viewModel.setUp)
		.onBackground(viewModel.stopRecording)
		.onForeground(viewModel.retake)
	}
}

private extension CameraView {
	func done() {
		self.viewModel.save {
			self.onFinish($0)
			self.dismiss()
		}
	}

	func process() {
		if self.viewModel.isRecording {
			self.viewModel.stopRecording()
		}
		else {
			self.viewModel.startRecordinng()
		}
	}
}

struct CameraView_Previews: PreviewProvider {
	static var previews: some View {
		CameraView { _ in }
	}
}
