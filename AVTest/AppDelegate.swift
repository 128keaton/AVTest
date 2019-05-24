//
//  AppDelegate.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/10/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private (set) public var audioPlayer: AVAudioPlayer?

    @IBOutlet var audioTestMenuItem: NSMenuItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupAudioPlayer()

        NotificationCenter.default.addObserver(self, selector: #selector(audioTestStarted), name: Notification.Name("AudioTestStartedFromView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioTestStopped), name: Notification.Name("AudioTestStoppedFromView"), object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    private func setupAudioPlayer() {
        let path = Bundle.main.path(forResource: "nt4", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            NotificationCenter.default.post(name: Notification.Name("AudioPlayerReady"), object: audioPlayer)
        } catch {
            print("Unable to load file")
        }
    }

    @objc func audioTestStarted() {
        audioTestMenuItem.title = "Stop Audio Test"
    }

    @objc func audioTestStopped() {
        audioTestMenuItem.title = "Start Audio Test"
    }

    @IBAction func playSound(_ sender: NSMenuItem) {
        audioTestMenuItem = sender
        if let currentPlayer = audioPlayer,
            currentPlayer.isPlaying {
            currentPlayer.stop()
            currentPlayer.currentTime = 0

            NotificationCenter.default.post(name: Notification.Name("AudioTestStoppedFromMenu"), object: nil)

            audioTestStopped()
        } else if let currentPlayer = audioPlayer {
            currentPlayer.play()

            NotificationCenter.default.post(name: Notification.Name("AudioTestStartedFromMenu"), object: nil)

            audioTestStarted()
        }
    }
}

extension AppDelegate: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name: Notification.Name("AudioTestStoppedFromMenu"), object: nil)
        audioTestStopped()
    }
}
