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
    @IBOutlet private var audioPreview: AudioPreview!

    @IBOutlet private var testAudioButton: NSButton!
    @IBOutlet private var noCameraLabel: NSTextField!
    @IBOutlet private var noMicrophoneLabel: NSTextField!
    @IBOutlet private var testingNotesTextView: NSTextView!

    @IBOutlet private var loadingView: LoadingView!

    private var mic: AKMicrophone!
    private var tracker: AKFrequencyTracker!
    private var silence: AKBooster!
    private var audioPlayer: AVAudioPlayer?
    private var machineInformationView: MachineInformationView? {
        didSet {
            if self.machineInformationView != nil {
                self.machineInformationView?.delegate = self
            }
        }
    }

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

        testAudioButton.isEnabled = false

        NotificationCenter.default.addObserver(self, selector: #selector(audioPlayerReady(_:)), name: Notification.Name("AudioPlayerReady"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioTestStarted), name: Notification.Name("AudioTestStartedFromMenu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioTestStopped), name: Notification.Name("AudioTestStoppedFromMenu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePrint), name: Notification.Name("PrintLabelFromMenu"), object: nil)

        SystemProfiler.delegate = self
        SystemProfiler.getInfo()

        setupAudioKit()
    }


    private func getSampleRate() {
        let outputDevice = Audio.getDefaultOutputDevice()
        AKSettings.sampleRate = Audio.getSampleRate(deviceID: outputDevice)
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
            return
        }
        hasMicrophone = true
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

        hasCamera = true
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

    @IBAction func playSound(_ sender: NSButton) {
        if let currentPlayer = audioPlayer,
            currentPlayer.isPlaying {
            stopAudioTest(withPlayer: currentPlayer)
        } else if let currentPlayer = audioPlayer {
            startAudioTest(withPlayer: currentPlayer)
        }
    }

    private func displayAlert(title: String, text: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = title.contains("Error") ? .critical : .informational
        alert.runModal()
    }

    private func displayAlert(error: Error) {
        NSAlert(error: error).runModal()
    }

    private func enableShowInternalDrivesMenuItem() {
        print("Enabling 'Show Internal Drives' menu item")
        NotificationCenter.default.post(name: Notification.Name("CanShowInternalDrivesMenuItem"), object: nil)
    }

    @objc private func handlePrint() {
        if let hardwareItem = SystemProfiler.hardwareItem,
            let machineInformationView = self.machineInformationView {

            hardwareItem.cpuType = machineInformationView.machineProcesser
            hardwareItem.physicalMemory = machineInformationView.machineMemory
            hardwareItem.configurationCode = machineInformationView.machineModel

            let testingNotes = self.testingNotesTextView.string.appending("\n\n\(hardwareItem.configurationCode)")
            let condensedSystemProfilerData = SystemProfiler.condense(withNotes: testingNotes)

            do {
                let encodedEvaluationData = try JSONEncoder().encode(condensedSystemProfilerData)
                PrintManager.printJSONData(encodedEvaluationData) { (success, message) in
                    if(!success) {
                        self.displayAlert(title: "Error", text: message)
                    } else if message == "Success" {
                        self.displayAlert(title: message, text: "Label was printed")
                    } else if let printServerURL = URL(string: Configuration.printServerAddress),
                        let host = printServerURL.host,
                        let scheme = printServerURL.scheme,
                        let baseURL = URL(string: "\(scheme)://\(host)") {
                        self.showWebWindow(content: message, baseURL: baseURL)
                    }
                }
            } catch {
                handleError(error)
            }
        }
    }

    private func showWebWindow(content: String, baseURL: URL) {
        let windowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "genericWebView") as! NSWindowController
        let webViewController = windowController.contentViewController as! GenericWebViewController

        webViewController.titleString = "Error Printing:"
        webViewController.contentString = content
        webViewController.baseURL = baseURL

        windowController.showWindow(self)
    }
}

extension TestViewController: MachineInformationViewDelegate {
    func printButtonClicked() {
        self.handlePrint()
    }
}

extension TestViewController: SystemProfilerDelegate {
    func dataParsedSuccessfully() {
        NotificationCenter.default.post(name: Notification.Name("CanPrintLabel"), object: nil)

        loadingView.hide {
            print("LoadingView hid")

            if let hardwareItem = SystemProfiler.hardwareItem {
                let newMachineInformationView = MachineInformationView(frame: self.loadingView.bounds, hidden: true, hardwareItem: hardwareItem)
                self.view.replaceSubviewPreservingConstraints(subview: self.loadingView, replacement: newMachineInformationView)

                if let powerBatteryItem = SystemProfiler.powerItems.first(where: { $0.battery != nil }),
                    let batteryItem = powerBatteryItem.battery,
                    let batteryHealth = batteryItem.healthInfo {

                    let batteryStatus = "\(batteryHealth.healthStatus) - (\(batteryHealth.cycleCount) cycles)"
                    newMachineInformationView.showBatteryHealth(batteryStatus: batteryStatus)
                }

                if SystemProfiler.NVMeItems.count > 0 || SystemProfiler.serialATAItems.count > 0 {
                    self.enableShowInternalDrivesMenuItem()
                }

                if newMachineInformationView.fieldsPopulated {
                    newMachineInformationView.show(animated: true, completion: {
                        print("MachineInformationView shown")
                        self.machineInformationView = newMachineInformationView
                    })
                }
            }
        }
    }

    func handleError(_ error: Error) {
        self.displayAlert(error: error)
    }
}
