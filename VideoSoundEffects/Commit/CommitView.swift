//
//  Created by Антон Лобанов on 03.11.2022.
//

import SwiftUI

struct CommitView: View {
	@ObservedObject var videoViewModel: VideoViewModel

	@Environment(\.dismiss) private var dismiss
	@StateObject private var playerViewModel = PlayerViewModel()

	@State private var shareItems: [URL] = []
	@State private var isShareSheetPresented = false
	@State private var error = false

    var body: some View {
		GeometryReader { geo in
			ZStack(alignment: .bottom) {
				VStack(alignment: .center) {
					PlayerView(viewModel: playerViewModel)
						.frame(height: geo.size.height * 0.4)
					Spacer()
				}
				.padding(.top)
				.frame(maxWidth: .infinity, maxHeight: .infinity)

				VStack {
					HStack {
						Spacer()
						Button(action: dismiss.callAsFunction) {
							Circle()
								.frame(width: 40, height: 40)
								.overlay {
									Image(systemName: "xmark")
										.tint(.white)
								}
						}
					}
					Spacer()
				}
				.frame(maxWidth: .infinity)
				.padding()

				VStack(spacing: 36) {
					Text("Sound Effects")
						.font(.system(.title3, design: .monospaced))
						.foregroundColor(.white)
						.padding(.top, 24)

					ScrollView(.horizontal, showsIndicators: false) {
						LazyHGrid(rows: [GridItem(.fixed(60), spacing: 16), GridItem(.fixed(60))], spacing: 16) {
							ForEach(Sound.allCases) { sound in
								Button(action: { playerViewModel.addAndPlaySound(sound) }) {
									Circle()
										.fill(.white)
										.overlay {
											Text(sound.emoji)
										}
								}
								.disabled(playerViewModel.exportProgress != nil)
							}
						}
						.padding(.leading)
					}

					Slider(
						value: $playerViewModel.currentTime,
						in: 0...playerViewModel.duration,
						step: 1
					) {
						Text("Speed").colorInvert()
					} minimumValueLabel: {
						Text(playerViewModel.formattedStartTime)
							.foregroundColor(.white)
							.font(.system(.footnote, design: .monospaced))
					} maximumValueLabel: {
						Text(playerViewModel.formattedEndTime)
							.foregroundColor(.white)
							.font(.system(.footnote, design: .monospaced))
					} onEditingChanged: { isEditing in
						playerViewModel.isEditingCurrentTime = isEditing
					}
					.tint(.white)
					.padding(.horizontal)
					.disabled(playerViewModel.exportProgress != nil)

					HStack {
						Button(action: {
							if playerViewModel.isPlaying {
								playerViewModel.player.pause()
							}
							else {
								playerViewModel.player.play()
							}
						}) {
							Circle()
								.fill(Color.white)
								.frame(width: 40, height: 40)
								.overlay {
									if playerViewModel.isPlaying {
										Image(systemName: "pause.fill")
											.tint(.accentColor)
									}
									else {
										Image(systemName: "play.fill")
											.tint(.accentColor)
									}
								}
						}
						.disabled(playerViewModel.exportProgress != nil)

						Button(action: done) {
							Text(playerViewModel.exportProgress.map { "\(Int($0 * 100))%" } ?? "Done")
								.foregroundColor(.accentColor)
								.font(.system(.headline, design: .monospaced))
								.frame(maxWidth: .infinity)
								.frame(height: 40)
								.background(
									RoundedRectangle(cornerRadius: 20)
										.fill(Color.white)
								)
						}
						.disabled(playerViewModel.exportProgress != nil || playerViewModel.tracks == 0)

						Button(action: playerViewModel.removeLastAudioTrack) {
							Circle()
								.fill(Color.white)
								.frame(width: 40, height: 40)
								.overlay {
									if playerViewModel.tracks > 0 {
										Text("\(playerViewModel.tracks)")
											.font(.system(.callout, design: .monospaced))
											.foregroundColor(.accentColor)
									}
									else {
										Image(systemName: "arrow.uturn.backward")
											.tint(.accentColor)
									}
								}
						}
						.disabled(playerViewModel.exportProgress != nil)
					}
					.padding(.horizontal)
				}
				.padding(.bottom, 24)
				.frame(maxWidth: .infinity)
				.background(
					RoundedRectangle(cornerRadius: 36)
						.fill(Color.accentColor)
						.ignoresSafeArea()
				)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
			.ignoresSafeArea(edges: .bottom)
		}
		.sheet(isPresented: $isShareSheetPresented) {
			ShareSheet(activityItems: shareItems)
		}
		.alert(isPresented: $error) {
			Alert(title: Text("Something went wrong😵"))
		}
		.toolbar(.hidden, for: .navigationBar)
		.onAppear(perform: fetchAsset)
		.onDisappear(perform: playerViewModel.player.pause)
    }
}

private extension CommitView {
	func fetchAsset() {
		self.videoViewModel.requestAVAsset { asset in
			guard let asset else {
				self.error = true
				return
			}
			self.playerViewModel.setAsset(asset)
			self.playerViewModel.player.play()
		}
	}

	func done() {
		self.playerViewModel.export { url in
			if let url {
				self.shareItems = [url]
				self.isShareSheetPresented = true
			}
			else {
				self.error = true
			}
		}
	}
}

private extension PlayerViewModel {
	var formattedStartTime: String {
		String(
			format: "%0.2d:%0.2d",
			(Int(self.currentTime) / 60) % 60,
			Int(self.currentTime) % 60
		)
	}

	var formattedEndTime: String {
		String(
			format: "%0.2d:%0.2d",
			(Int(self.duration - self.currentTime) / 60) % 60,
			Int(self.duration - self.currentTime) % 60
		)
	}
}

struct CommitView_Previews: PreviewProvider {
    static var previews: some View {
		CommitView(videoViewModel: VideoViewModel(asset: .init()))
    }
}

