//
//  TestViewController.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/10/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Cocoa
import AudioKit
import AudioKitUI

class TestViewController: NSViewController {
    @IBOutlet var cameraPreview: CameraPreview!
    @IBOutlet private var testAudioButton: NSButton!
    @IBOutlet private var audioPreview: AudioPreview!

    private var mic: AKMicrophone!
    private var tracker: AKFrequencyTracker!
    private var silence: AKBooster!
    private var audioPlayer: AVAudioPlayer?
    private var hasMicrophone: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true

        testAudioButton.isEnabled = false

        NotificationCenter.default.addObserver(self, selector: #selector(audioPlayerReady(_:)), name: Notification.Name("AudioPlayerReady"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioTestStarted), name: Notification.Name("AudioTestStartedFromMenu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioTestStopped), name: Notification.Name("AudioTestStoppedFromMenu"), object: nil)

        setupAudioKit()
    }

    private func getSampleRate() {
        let inputDevice = Audio.getDefaultInputDevice()
        AKSettings.sampleRate = Audio.getSampleRate(deviceID: inputDevice)
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        startCameraSession()
        setupAudioPreview()
        startAudioKit()
    }

    private func startAudioKit() {
        AudioKit.output = silence
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }

    private func setupAudioKit() {
        getSampleRate()
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
    }

    private func startCameraSession() {
        cameraPreview.wantsLayer = true

        let session = AVCaptureSession()
        session.sessionPreset = .low

        guard let device = AVCaptureDevice.default(for: .video)
            else {
                return
        }

        let deviceInput = try! AVCaptureDeviceInput(device: device)

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = cameraPreview.bounds
        previewLayer.videoGravity = .resizeAspectFill

        self.cameraPreview.layer?.addSublayer(previewLayer)

        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }

        session.startRunning()
    }

    private func setupAudioPreview() {
        let outputPlot = AKNodeOutputPlot(mic, frame: audioPreview.bounds)
        outputPlot.plotType = .rolling
        outputPlot.shouldFill = true
        outputPlot.shouldMirror = true
        outputPlot.gain = 5.0
        outputPlot.color = NSColor(deviceRed: 14.0 / 255, green: 122.0 / 255, blue: 254.0 / 255, alpha: 1.0)
        outputPlot.backgroundColor = NSColor.clear
        outputPlot.autoresizingMask = NSView.AutoresizingMask.width
        audioPreview.addSubview(outputPlot)
    }

    private func startAudioTest(withPlayer currentPlayer: AVAudioPlayer) {
        DispatchQueue.main.async {
            currentPlayer.play()
            NotificationCenter.default.post(name: Notification.Name("AudioTestStartedFromView"), object: nil)
            self.audioTestStarted()
        }
    }

    private func stopAudioTest(withPlayer currentPlayer: AVAudioPlayer) {
        DispatchQueue.main.async {
            currentPlayer.stop()
            currentPlayer.currentTime = 0

            NotificationCenter.default.post(name: Notification.Name("AudioTestStoppedFromView"), object: nil)

            self.audioTestStopped()
        }
    }

    @objc func audioPlayerReady(_ notification: Notification) {
        if let validAudioPlayer = notification.object as? AVAudioPlayer {
            self.audioPlayer = validAudioPlayer
            self.testAudioButton.isEnabled = true
        }
    }

    @objc func audioTestStarted() {
        testAudioButton.title = "Stop Audio Test"
    }

    @objc func audioTestStopped() {
        testAudioButton.title = "Start Audio Test"
    }

    @IBAction func testParse(_ sender: NSButton) {
        SystemProfiler.testParse()
    }

    @IBAction func printLabels(_ sender: NSButton) {
        SystemProfiler.getInfo()
    }

    @IBAction func playSound(_ sender: NSButton) {
        if let currentPlayer = audioPlayer,
            currentPlayer.isPlaying {
            stopAudioTest(withPlayer: currentPlayer)
        } else if let currentPlayer = audioPlayer {
            startAudioTest(withPlayer: currentPlayer)
        }
    }
}

