//
//  Created by Антон Лобанов on 03.11.2022.
//

import SwiftUI

struct PlayerView: View {
    @StateObject private var viewModel = PlayerViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            if viewModel.isPlayerReady {
                RoundedRectangle(cornerRadius: 36)
                    .fill(.black)
                    .frame(maxHeight: .infinity)
                    .overlay(
                        PlayerContentView(configurator: viewModel)
                    )
                    .clipped()
            }

            navigationView
                .padding(.top, 36)
                .padding(.horizontal, 36)

            if viewModel.isPlayerReady {
                controlsView
                    .padding()
            }

            if viewModel.isExporting {
                VStack {
                    Spacer()

                    ProgressView()
                        .tint(.white)
                        .progressViewStyle(CircularProgressViewStyle())

                    Spacer()
                }
                .padding()
            }
        }
        .sheet(item: $viewModel.exportedFileURL) {
            ShareSheet(activityItems: [$0])
        }
        .alert(isPresented: $viewModel.error) {
            Alert(title: Text("Something went wrong😵"))
        }
        .onDisappear(perform: viewModel.pause)
        .onBackground(viewModel.pause)
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}

private extension PlayerView {
    var navigationView: some View {
        VStack {
            if viewModel.isPlayerReady {
                navigationControlsView
                Spacer()
            }
            else if viewModel.isExporting == false {
                Spacer()
                selectButton
                Spacer()
            }
        }
    }

    var navigationControlsView: some View {
        HStack(spacing: 16) {
            Button(action: viewModel.export) {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(.title3))
                            .tint(.white)
                    }
            }

            Spacer()

            selectButton
        }
    }

    var selectButton: some View {
        NavigationLink(destination: LibraryView(onSelect: viewModel.setAsset)) {
            Text("Select")
                .foregroundColor(.accentColor)
                .font(.system(.headline, design: .monospaced))
                .padding()
                .background(Capsule().fill(.white))
        }
    }

    var controlsView: some View {
        VStack {
            if
                viewModel.isPlayerReady &&
                viewModel.isPlaying == false &&
                viewModel.isExporting == false
            {
                Spacer()

                audioControlButtons
                    .padding(.bottom)
            }

            Spacer()

            if viewModel.isPlayerReady {
                adjustmentControlsView
                    .disabled(viewModel.isExporting)
            }

            if viewModel.isPlayerReady == false {
                Spacer()
            }
        }
        .padding(.horizontal)
    }

    var adjustmentControlsView: some View {
        VStack {
            HStack(spacing: 24) {
                ForEach(viewModel.allPlaybackPitches.indices) { index in
                    Button(action: { viewModel.playbackPitchIndex = index }) {
                        Circle()
                            .fill(viewModel.playbackPitchIndex == index ? Color.accentColor : Color.white)
                            .frame(width: 60, height: 60)
                            .overlay {
                                Text(viewModel.allPlaybackPitches[index].label)
                            }
                    }
                }
            }
        }
        .padding()
    }

    var audioControlButtons: some View {
        HStack(spacing: 20) {
            Spacer()

            Button {
                viewModel.isPlaying ? viewModel.pause() : viewModel.play()
            } label: {
                ZStack {
                    viewModel.isPlaying ? Image(systemName: "pause.fill") : Image(systemName: "play.fill")
                }
            }
            .frame(width: 40)
            .font(.system(size: 45))

            Spacer()
        }
        .foregroundColor(.primary)
        .padding(.vertical, 20)
        .frame(height: 58)
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PlayerView()
        }
    }
}

extension URL: Identifiable {
    public var id: String {
        self.absoluteString
    }
}
