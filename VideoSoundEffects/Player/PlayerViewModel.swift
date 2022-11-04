//
//  Created by Антон Лобанов on 03.11.2022.
//

import AVKit
import Combine

final class PlayerViewModel: ObservableObject {
	let player = AVPlayer()

	@Published var exportProgress: Float?
	@Published var isPlaying = false
	@Published var isEditingCurrentTime = false
	@Published var currentTime = 0.0
	@Published var duration = 1.0
	@Published var tracks = 0

	private var isSeeking = false
	private var subscriptions: Set<AnyCancellable> = []
	private var timeObserver: Any?
	private var composition = AVMutableComposition()
	private var audioPlayers: [AVPlayer] = []
	private var audioTracks: [AVAssetTrack] = []
	private var exportTimer: Timer?
	private var exportSession: AVAssetExportSession?

	private let fileManager = FileManager.default

	deinit {
		if let timeObserver = self.timeObserver {
			self.player.removeTimeObserver(timeObserver)
		}
		self.exportTimer?.invalidate()
		self.exportSession?.cancelExport()
	}

	init() {
		self.$isEditingCurrentTime
			.dropFirst()
			.filter { $0 == false }
			.sink(receiveValue: { [weak self] _ in
				guard let self else { return }
				let seekTime = CMTime(seconds: self.currentTime, preferredTimescale: 1)
				self.isSeeking = true
				self.audioPlayers.forEach { $0.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero) }
				self.player.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
					self?.isSeeking = false
				}
				if self.player.rate != 0 { self.player.play() }
			})
			.store(in: &self.subscriptions)

		self.player.publisher(for: \.timeControlStatus)
			.sink { [weak self] status in
				switch status {
				case .playing:
					self?.isPlaying = true
					self?.audioPlayers.forEach { $0.play() }
				case .paused:
					self?.isPlaying = false
					self?.audioPlayers.forEach { $0.pause() }
				case .waitingToPlayAtSpecifiedRate:
					break
				@unknown default:
					break
				}
			}
			.store(in: &self.subscriptions)

		self.timeObserver = self.player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
			guard let self else { return }
			if self.isEditingCurrentTime == false, self.isSeeking == false {
				self.currentTime = time.seconds
			}
		}
	}

	func setAsset(_ asset: AVAsset) {
		self.composition = AVMutableComposition()
		self.audioTracks = []
		self.audioPlayers = []
		self.currentTime = 0
		self.duration = 1.0

		if let videoTrack = asset.firstTrack(of: .video) {
			self.composition.insertTrack(videoTrack, mediaType: .video, at: .zero)
		}

		if let audioTrack = asset.firstTrack(of: .audio) {
			self.composition.insertTrack(audioTrack, mediaType: .audio, at: .zero)
		}

		let item = AVPlayerItem(asset: asset)

		item.publisher(for: \.status)
			.filter { $0 == .readyToPlay }
			.sink(receiveValue: { [weak self] _ in
				self?.duration = item.asset.duration.seconds
			})
			.store(in: &self.subscriptions)

		self.player.replaceCurrentItem(with: item)
	}

	func addAndPlaySound(_ sound: Sound) {
		guard let audioPath = Bundle.main.path(forResource: sound.fileName, ofType: sound.fileType) else {
			return
		}

		let seekTime = CMTime(value: CMTimeValue(self.currentTime), timescale: 1)
		let audioUrl = URL(fileURLWithPath: audioPath)
		let audioComposition = AVMutableComposition()
		let audioAsset = AVURLAsset(url: audioUrl)
		let audioItem = AVPlayerItem(asset: audioComposition)
		let audioPlayer = AVPlayer(playerItem: audioItem)

		guard let audioTrack = audioAsset.firstTrack(of: .audio) else { return }

		self.composition.insertTrack(audioTrack, mediaType: .audio, at: seekTime)
		audioComposition.insertTrack(audioTrack, mediaType: .audio, at: seekTime)
		audioPlayer.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)

		if self.isPlaying {
			audioPlayer.play()
		}

		self.tracks += 1
		self.audioTracks.append(audioTrack)
		self.audioPlayers.append(audioPlayer)
	}

	// TODO: What if the last audio and composition track different?
	func removeLastAudioTrack() {
		guard self.audioTracks.isEmpty == false else { return }

		self.audioTracks.removeLast()
		self.audioPlayers.removeLast()

		if let compositionTrack = self.composition.tracks.last {
			self.composition.removeTrack(compositionTrack)
		}

		self.tracks -= 1
	}

	func export(with completion: @escaping (URL?) -> Void) {
		let dirPaths = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)
		let fileName = "VideoSoundEffects_Video.mp4"
		let fileUrl = dirPaths[0].appendingPathComponent(fileName)

		self.player.pause()
		self.exportSession?.cancelExport()
		self.exportTimer?.invalidate()
		try? self.fileManager.removeItem(at: fileUrl)

		self.exportSession = AVAssetExportSession(asset: self.composition, presetName: AVAssetExportPresetHighestQuality)
		self.exportSession?.outputURL = fileUrl
		self.exportSession?.outputFileType = .mp4

		self.exportSession?.exportAsynchronously { [weak self] in
			onMainThread {
				let isSuccess = (self?.exportSession?.status == .completed)
				completion(isSuccess ? fileUrl : nil)
				self?.exportTimer?.invalidate()
				self?.exportProgress = nil
			}
		}

		self.exportTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
			self?.exportProgress = self?.exportSession?.progress
		}
	}
}

private extension AVAsset {
	func firstTrack(of mediaType: AVMediaType) -> AVAssetTrack? {
		self.tracks(withMediaType: mediaType).first
	}
}

private extension AVMutableComposition {
	func insertTrack(_ track: AVAssetTrack, mediaType: AVMediaType, at time: CMTime) {
		let compositionTrack = self.addMutableTrack(withMediaType: mediaType, preferredTrackID: track.trackID)
		try? compositionTrack?.insertTimeRange(
			CMTimeRange(start: .zero, duration: track.duration),
			of: track,
			at: time
		)
		compositionTrack?.preferredTransform = track.preferredTransform
	}
}

private extension AVAssetTrack {
	var duration: CMTime {
		self.timeRange.duration
	}
}
