//
//  Created by Антон Лобанов on 03.11.2022.
//

import PhotosUI
import SwiftUI

struct LibraryView: View {
    let onSelect: (AVAsset?) -> Void

    @State private var videos: [VideoViewModel] = []
    @State private var isCameraPresented = false

    @Environment(\.dismiss) private var dismiss

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
                            Button {
                                video.requestAVAsset(completion: onSelect)
                                dismiss()
                            } label: {
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
                Button {
                    isCameraPresented.toggle()
                } label: {
                    Text("Camera")
                        .font(.system(.body, design: .monospaced))
                }
                .controlSize(.small)
                .buttonStyle(.borderedProminent)
            }
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraView(onFinish: fetchVideos)
        }
        .navigationTitle("Videos")
        .onAppear(perform: fetchVideos)
        .onForeground(fetchVideos)
    }
}

private extension LibraryView {
    func fetchVideos() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(with: .video, options: options)
        var videos: [VideoViewModel] = []
        result.enumerateObjects { asset, _, _ in videos.append(.init(asset: asset)) }
        self.videos = videos
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LibraryView { _ in }
        }
    }
}
