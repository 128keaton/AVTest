//
//  ViewController.swift
//  CameraTest
//
//  Created by Keaton Burleson on 8/22/18.
//  Copyright © 2018 Keaton Burleson. All rights reserved.
//

import Cocoa
import AVKit
import AudioKit
import AudioKitUI
import AVFoundation

class ViewController: NSViewController {
    @IBOutlet var cameraPreview: CameraPreview!
    @IBOutlet var audioInputPlot: EZAudioPlot!

    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    var youSuffer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true

        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
    }

    func setupPlot() {
        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.gain = 5.0
        plot.color = NSColor.white
        plot.backgroundColor = NSColor.black
        plot.autoresizingMask = NSView.AutoresizingMask.width
        audioInputPlot.addSubview(plot)
    }


    override func viewDidAppear() {
        setupPlot()
        cameraPreview.wantsLayer = true

        let session = AVCaptureSession()
        session.sessionPreset = .low

        guard let device = AVCaptureDevice.default(for: .video)
            else {
                return
        }

        print(device)

        let deviceInput = try! AVCaptureDeviceInput(device: device)

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = cameraPreview.bounds
        previewLayer.videoGravity = .resizeAspectFill

        self.cameraPreview.layer?.addSublayer(previewLayer)
        //  self.view.layer?.addSublayer(previewLayer)
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }

        session.startRunning()

        AudioKit.output = silence
        AudioKit.start()
    }
    
    @IBAction func playSound(sender: NSButton){
        
        let path = Bundle.main.path(forResource: "YOUSUFFER.m4a", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            youSuffer = try AVAudioPlayer(contentsOf: url)
            youSuffer?.play()
        } catch {
            print("Unable to load file")
        }
      
    }
}

