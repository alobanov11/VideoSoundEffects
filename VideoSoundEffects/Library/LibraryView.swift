//
//  Created by Антон Лобанов on 03.11.2022.
//

import PhotosUI
import SwiftUI

struct LibraryView: View {
	@State private var videos: [VideoViewModel] = []
	@State private var isCameraPresented = false

	var body: some View {
		ZStack {
			if videos.isEmpty {
				Text("You library is boring and empty")
					.multilineTextAlignment(.center)
					.font(.system(.callout, design: .monospaced))
					.padding(.horizontal)
			}
			else {
				ScrollView {
					LazyVGrid(
						columns: [
							.init(.flexible(), spacing: 18),
							.init(.flexible(), spacing: 18),
						],
						spacing: 18
					) {
						ForEach(videos) { video in
							NavigationLink(value: video) {
								VideoRowItemView(viewModel: video)
							}
						}
					}
					.padding()
				}
			}
		}
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button(action: { isCameraPresented.toggle() }) {
					Text("Camera")
						.font(.system(.body, design: .monospaced))
				}
				.controlSize(.small)
				.buttonStyle(.borderedProminent)
			}
		}
		.fullScreenCover(isPresented: $isCameraPresented) {
			CameraView { _ in
				fetchVideos()
			}
		}
		.navigationTitle("Videos")
		.navigationDestination(for: VideoViewModel.self) {
			CommitView(videoViewModel: $0)
		}
		.onAppear(perform: fetchVideos)
		.onForeground(fetchVideos)
	}
}

private extension LibraryView {
	func fetchVideos() {
		onBackgroundThread {
			let options = PHFetchOptions()
			options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
			let result = PHAsset.fetchAssets(with: .video, options: options)
			var videos: [VideoViewModel] = []
			result.enumerateObjects { asset, _, _ in videos.append(.init(asset: asset)) }
			onMainThread { self.videos = videos }
		}
	}
}

struct LibraryView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationStack {
			LibraryView()
		}
	}
}
