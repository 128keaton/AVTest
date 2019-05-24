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

    @IBOutlet private var testAudioItem: NSMenuItem!
    @IBOutlet private var printLabelsItem: NSMenuItem!

    @IBOutlet private var audioPreview: AudioPreview!

    @IBOutlet private var noCameraLabel: NSTextField!
    @IBOutlet private var noMicrophoneLabel: NSTextField!

    @IBOutlet private var machineModelLabel: NSTextField!
    @IBOutlet private var machineMemoryLabel: NSTextField!
    @IBOutlet private var machineProcessorLabel: NSTextField!

    private var selectedAction: () -> () = { }
    private var mic: AKMicrophone!
    private var tracker: AKFrequencyTracker!
    private var silence: AKBooster!
    private var audioPlayer: AVAudioPlayer?

    private var hasMicrophone: Bool {
        set {
            self.noMicrophoneLabel.isHidden = newValue
        }
        get {
            return self.noMicrophoneLabel.isHidden
        }
    }

    private var hasCamera: Bool {
        set {
            self.noCameraLabel.isHidden = newValue
        }
        get {
            return self.noCameraLabel.isHidden
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true

        testAudioItem.isEnabled = false
        selectedAction = playSound

        NotificationCenter.default.addObserver(self, selector: #selector(audioPlayerReady(_:)), name: Notification.Name("AudioPlayerReady"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioTestStarted), name: Notification.Name("AudioTestStartedFromMenu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioTestStopped), name: Notification.Name("AudioTestStoppedFromMenu"), object: nil)

                SystemProfiler.testGetInfo()
        
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
            self.hasMicrophone = false
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
                hasCamera = false
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
            self.testAudioItem.isEnabled = true
        }
    }

    @objc func audioTestStarted() {
        testAudioItem.title = "Stop Audio Test"
    }

    @objc func audioTestStopped() {
        testAudioItem.title = "Start Audio Test"
    }

    @IBAction func performAction(_ sender: NSButton) {
        selectedAction()
    }

    @IBAction func actionChanged(_ sender: NSPopUpButton) {
        if sender.selectedItem == testAudioItem {
            selectedAction = playSound
        } else if sender.selectedItem == printLabelsItem {
            selectedAction = printLabels
        }
    }

    private func printLabels() {
        SystemProfiler.testGetInfo()
        //  SystemProfiler.getInfo()
    }

    private func playSound() {
        if let currentPlayer = audioPlayer,
            currentPlayer.isPlaying {
            stopAudioTest(withPlayer: currentPlayer)
        } else if let currentPlayer = audioPlayer {
            startAudioTest(withPlayer: currentPlayer)
        }
    }
}

