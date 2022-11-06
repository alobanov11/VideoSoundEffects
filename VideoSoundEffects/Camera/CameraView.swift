//
//  Created by Антон Лобанов on 03.11.2022.
//

import SwiftUI

struct CameraView: View {
    let onFinish: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var viewModel = CameraViewModel()

    var body: some View {
        ZStack {
            CameraContentView(configurator: viewModel)
                .ignoresSafeArea()

            if let url = viewModel.previewURL {
                CameraContentPreview(url: url)
                    .ignoresSafeArea()
            }

            controlsView
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
    var controlsView: some View {
        VStack {
            navigationControlsView
                .padding(.top)
                .padding(.horizontal)

            Spacer()

            adjustmentControlsView
                .padding(.bottom)
        }
    }

    var navigationControlsView: some View {
        HStack {
            if viewModel.previewURL != nil {
                Button(action: viewModel.retake) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }
            }
            else {
                Button(action: dismiss.callAsFunction) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }
            }

            Spacer()
        }
    }

    var adjustmentControlsView: some View {
        HStack {
            if viewModel.previewURL != nil {
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
    }
}

private extension CameraView {
    func done() {
        self.viewModel.save {
            self.onFinish()
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
        CameraView {}
    }
}
