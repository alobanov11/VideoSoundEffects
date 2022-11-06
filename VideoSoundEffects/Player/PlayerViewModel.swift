//
//  Created by Антон Лобанов on 03.11.2022.
//

import AVFoundation
import SwiftUI

final class PlayerViewModel: NSObject, ObservableObject, IPlayerContentLayerConfigurator {
    @Published var error = false
    @Published var exportedFileURL: URL?

    var playbackPitchIndex = 1 {
        willSet {
            objectWillChange.send()
        }
        didSet {
            self.updateForPitchSelection(self.audioTimePitch)
        }
    }

    private(set) var isExporting = false {
        willSet {
            withAnimation {
                objectWillChange.send()
            }
        }
    }

    private(set) var isPlaying = false {
        willSet {
            withAnimation {
                objectWillChange.send()
            }
        }
    }

    private(set) var isPlayerReady = false {
        willSet {
            withAnimation {
                objectWillChange.send()
            }
        }
    }

    let allPlaybackPitches: [PlaybackValue] = [
        .init(value: -0.5, label: "👹"),
        .init(value: 0, label: "😐"),
        .init(value: 0.5, label: "👶"),
    ]

    private var currentFrame: AVAudioFramePosition {
        guard
            let lastRenderTime = audioPlayerNode.lastRenderTime,
            let playerTime = audioPlayerNode.playerTime(forNodeTime: lastRenderTime)
        else {
            return 0
        }

        return playerTime.sampleTime
    }

    private lazy var inputFileURL = self.fileManager.fileURLinDocumentDirectory(with: "VideoSoundEffects_Input.mp4")
    private lazy var outputFileURL = self.fileManager.fileURLinDocumentDirectory(with: "VideoSoundEffects_Output.mp4")
    private lazy var finalFileURL = self.fileManager.fileURLinDocumentDirectory(with: "VideoSoundEffects.mp4")

    private var displayLink: CADisplayLink?

    private var exportSession: AVAssetExportSession?

    private var audioFile: AVAudioFile?
    private var audioSampleRate: Double = 0
    private var audioLengthSeconds: Double = 0

    private var seekFrame: AVAudioFramePosition = 0
    private var currentPosition: AVAudioFramePosition = 0
    private var audioLengthSamples: AVAudioFramePosition = 0

    private var needsFileScheduled = true

    private let player = AVPlayer()
    private let audioEngine = AVAudioEngine()
    private let audioPlayerNode = AVAudioPlayerNode()
    private let audioTimePitch = AVAudioUnitTimePitch()

    private let fileManager = FileManager.default

    deinit {
        self.displayLink?.invalidate()
        self.exportSession?.cancelExport()
    }

    func configureLayer(_ layer: IPlayerContentLayer) {
        layer.player = self.player
    }

    func setAsset(_ asset: AVAsset?) {
        guard let asset else {
            self.error = true
            return
        }

        self.pause()
        self.prepareAsset(asset)
    }

    func play() {
        guard self.isPlaying == false else { return }

        self.isPlaying = true
        self.displayLink?.isPaused = false

        if self.needsFileScheduled {
            self.scheduleAudioFile()
        }

        self.audioPlayerNode.play()
        self.player.play()
    }

    func pause() {
        guard self.isPlaying else { return }

        self.isPlaying = false
        self.displayLink?.isPaused = true

        self.audioPlayerNode.pause()
        self.player.pause()
    }

    func export() {
        onBackgroundThread { [weak self] in
            self?.prepareExport()
        }

        self.pause()
    }
}

private extension PlayerViewModel {
    func prepareAsset(_ asset: AVAsset) {
        try? self.fileManager.removeItem(at: self.inputFileURL)

        self.exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
        self.exportSession?.outputURL = self.inputFileURL
        self.exportSession?.outputFileType = .mp4

        self.isExporting = true
        self.isPlayerReady = false

        self.exportSession?.exportAsynchronously { [weak self] in
            onMainThread {
                if self?.exportSession?.status == .completed {
                    self?.setupAudio()
                    self?.setupDisplayLink()
                }
                else {
                    self?.error = true
                }

                self?.isExporting = false
            }
        }
    }

    func setupAudio() {
        do {
            let file = try AVAudioFile(forReading: self.inputFileURL)
            let format = file.processingFormat

            self.audioLengthSamples = file.length
            self.audioSampleRate = format.sampleRate
            self.audioLengthSeconds = Double(self.audioLengthSamples) / self.audioSampleRate

            self.audioFile = file

            self.configureEngine(with: format)
        }
        catch {
            print("Error reading the audio file: \(error.localizedDescription)")
            self.error = true
        }
    }

    func configureEngine(with format: AVAudioFormat) {
        self.audioEngine.stop()

        self.audioEngine.attach(self.audioPlayerNode)
        self.audioEngine.attach(self.audioTimePitch)

        self.audioEngine.connect(
            self.audioPlayerNode,
            to: self.audioTimePitch,
            format: format
        )

        self.audioEngine.connect(
            self.audioTimePitch,
            to: self.audioEngine.mainMixerNode,
            format: format
        )

        self.audioEngine.prepare()

        do {
            try self.audioEngine.start()

            self.scheduleVideoFile()
            self.scheduleAudioFile()

            self.isPlayerReady = true
        }
        catch {
            print("Error starting the player: \(error.localizedDescription)")
            self.error = true
        }
    }

    func scheduleVideoFile() {
        let item = AVPlayerItem(url: self.inputFileURL)
        self.player.replaceCurrentItem(with: item)
        self.player.isMuted = true
    }

    func scheduleAudioFile() {
        guard
            let file = audioFile,
            needsFileScheduled
        else {
            return
        }

        self.needsFileScheduled = false
        self.seekFrame = 0

        self.audioPlayerNode.scheduleFile(file, at: nil) { [weak self] in
            self?.needsFileScheduled = true
        }
    }

    func seek(to time: Double) {
        guard let audioFile = audioFile else {
            return
        }

        let offset = AVAudioFramePosition(time * self.audioSampleRate)

        self.seekFrame = self.currentPosition + offset
        self.seekFrame = max(self.seekFrame, 0)
        self.seekFrame = min(self.seekFrame, self.audioLengthSamples)
        self.currentPosition = self.seekFrame

        let wasPlaying = self.audioPlayerNode.isPlaying

        self.audioPlayerNode.stop()

        if self.currentPosition < self.audioLengthSamples {
            self.updateDisplay()
            self.needsFileScheduled = false

            let frameCount = AVAudioFrameCount(audioLengthSamples - self.seekFrame)

            self.audioPlayerNode.scheduleSegment(
                audioFile,
                startingFrame: self.seekFrame,
                frameCount: frameCount,
                at: nil
            ) { [weak self] in
                self?.needsFileScheduled = true
            }

            if wasPlaying {
                self.audioPlayerNode.play()
            }
        }
    }

    func updateForPitchSelection(_ timePitch: AVAudioUnitTimePitch) {
        let selectedPitch = self.allPlaybackPitches[self.playbackPitchIndex]
        timePitch.pitch = 1200 * Float(selectedPitch.value)
    }

    func setupDisplayLink() {
        self.displayLink = CADisplayLink(
            target: self,
            selector: #selector(self.updateDisplay)
        )
        self.displayLink?.add(to: .current, forMode: .default)
        self.displayLink?.isPaused = true
    }

    @objc func updateDisplay() {
        self.currentPosition = self.currentFrame + self.seekFrame
        self.currentPosition = max(self.currentPosition, 0)
        self.currentPosition = min(self.currentPosition, self.audioLengthSamples)

        if self.currentPosition >= self.audioLengthSamples {
            self.audioPlayerNode.stop()

            self.player.pause()
            self.player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)

            self.seekFrame = 0
            self.currentPosition = 0

            self.isPlaying = false
            self.displayLink?.isPaused = true
        }
    }
}

private extension PlayerViewModel {
    func prepareExport() {
        try? self.fileManager.removeItem(at: self.outputFileURL)
        try? self.fileManager.removeItem(at: self.finalFileURL)

        self.fileManager.createFile(atPath: self.outputFileURL.path, contents: nil)

        onMainThread {
            self.isExporting = true
        }

        do {
            try self.saveOutput()
            self.exportOutput()
        }
        catch {
            print("Error saving output: \(error.localizedDescription)")
            self.error = true
        }
    }

    func saveOutput() throws {
        let sourceFile = try AVAudioFile(forReading: self.inputFileURL)
        let format = sourceFile.processingFormat

        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        let timePitch = AVAudioUnitTimePitch()

        engine.attach(player)
        engine.attach(timePitch)

        self.updateForPitchSelection(timePitch)

        engine.connect(player, to: timePitch, format: format)
        engine.connect(timePitch, to: engine.mainMixerNode, format: format)

        player.scheduleFile(sourceFile, at: nil)

        let maxFrames: AVAudioFrameCount = 4096
        try engine.enableManualRenderingMode(.offline, format: format, maximumFrameCount: maxFrames)

        try engine.start()
        player.play()

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: engine.manualRenderingFormat,
            frameCapacity: engine.manualRenderingMaximumFrameCount
        ) else {
            throw NSError()
        }

        let outputFile = try AVAudioFile(forWriting: self.outputFileURL, settings: sourceFile.fileFormat.settings)

        while engine.manualRenderingSampleTime < sourceFile.length {
            let frameCount = sourceFile.length - engine.manualRenderingSampleTime
            let framesToRender = min(AVAudioFrameCount(frameCount), buffer.frameCapacity)

            let status = try engine.renderOffline(framesToRender, to: buffer)

            switch status {
            case .success:
                try outputFile.write(from: buffer)

            case .insufficientDataFromInputNode:
                break

            case .cannotDoInCurrentContext:
                break

            case .error:
                throw NSError()

            @unknown default:
                break
            }
        }

        player.stop()
        engine.stop()
    }

    func exportOutput() {
        let outputURL = self.finalFileURL
        let composition = AVMutableComposition()
        let videoAsset = AVAsset(url: self.inputFileURL)
        let audioAsset = AVAsset(url: self.outputFileURL)

        if let videoTrack = videoAsset.firstTrack(of: .video) {
            composition.insertTrack(videoTrack, mediaType: .video, at: .zero)
        }

        if let audioTrack = audioAsset.firstTrack(of: .audio) {
            composition.insertTrack(audioTrack, mediaType: .audio, at: .zero)
        }

        self.exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)
        self.exportSession?.outputURL = outputURL
        self.exportSession?.outputFileType = .mp4

        self.exportSession?.exportAsynchronously { [weak self] in
            onMainThread {
                if self?.exportSession?.status == .completed {
                    self?.exportedFileURL = outputURL
                }
                else {
                    self?.error = true
                }

                self?.isExporting = false
            }
        }
    }
}

private extension FileManager {
    func fileURLinDocumentDirectory(with fileName: String) -> URL {
        let dirPaths = self.urls(for: .documentDirectory, in: .userDomainMask)
        let fileUrl = dirPaths[0].appendingPathComponent(fileName)
        return fileUrl
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
