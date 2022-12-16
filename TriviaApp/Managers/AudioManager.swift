//
//  AudioManager.swift
//  TriviaApp
//
//  Created by Tino on 16/12/2022.
//

import Foundation
import AVFAudio
import os

/// Manager for playing audio in the app.
final class AudioManager: ObservableObject {
    private var log = Logger(subsystem: "com.tinotusa.TriviaApp", category: "AudioManager")
    
    private var player: AVAudioPlayer?
    
    /// Plays the given audio file.
    /// - Parameter audioFile: The audio file to play
    func playSound(_ audioFile: AudioFile, volume: Float = 0.65) {
        log.debug("Playing sound.")
        
        guard let url = Bundle.main.url(forResource: audioFile.filename, withExtension: audioFile.extension) else {
            log.error("Failed to get audio file url.")
            return
        }
        
        do {
            player = try .init(contentsOf: url)
            player?.volume = min(1, max(0, volume))
            player?.prepareToPlay()
            player?.play()
            log.debug("Successfully played audio")
        } catch {
            log.error("Failed to play audio. \(error)")
        }
    }
}

extension AudioManager {
    /// Audio files the app can play.
    enum AudioFile: String {
        case defaultButton = "click2.wav"
        case correctAnswer = "correct-choice.wav"
        case triviaRoundComplete = "Win sound.wav"
        
        /// The name of the file.
        var filename: String {
            String(self.rawValue.split(separator: ".").first!)
        }
        
        /// The extension of the file.
        var `extension`: String {
            String(self.rawValue.split(separator: ".").last!)
        }
    }
}
