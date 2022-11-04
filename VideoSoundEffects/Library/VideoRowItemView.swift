//
//  Created by Антон Лобанов on 03.11.2022.
//

import SwiftUI
import PhotosUI

struct VideoRowItemView: View {
	@ObservedObject var viewModel: VideoViewModel

	var body: some View {
		Image(uiImage: viewModel.image ?? UIImage())
			.resizable()
			.scaledToFill()
			.frame(minWidth: 0, maxWidth: .infinity)
			.frame(height: UIScreen.main.bounds.height * 0.3)
			.overlay(alignment: .bottomTrailing) {
				Text(viewModel.formattedDuration)
					.foregroundColor(.white)
					.font(.system(.body, design: .monospaced))
					.padding(.bottom)
					.padding(.trailing)
			}
			.cornerRadius(10)
			.shadow(color: Color.primary.opacity(0.3), radius: 1)
			.onAppear(perform: viewModel.requestImage)
	}
}

private extension VideoViewModel {
	var formattedDuration: String {
		String(
			format: "%0.2d:%0.2d",
			(Int(self.duration) / 60) % 60,
			Int(self.duration) % 60
		)
	}
}

struct VideoRowItemView_Previews: PreviewProvider {
	static var previews: some View {
		VideoRowItemView(viewModel: VideoViewModel(asset: PHAsset()))
			.previewLayout(.fixed(width: 150, height: 300))
	}
}
