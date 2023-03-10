//
//  HapticManager.swift
//  TriviaApp
//
//  Created by Tino on 16/12/2022.
//

import Foundation
import CoreHaptics
import os

final class HapticsManager: ObservableObject {
    private var engine: CHHapticEngine?
    private let log = Logger(subsystem: "com.tinotusa.TriviaApp", category: "HapticManager")
    private var restartAttempts = 0
    private let maxRestartAttempts = 3
    private var audioManager = AudioManager()
    
    /// Creates the haptic manager.
    init() {
        if !CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            log.debug("Haptics not supported for this device.")
            return
        }
        do {
            engine = try CHHapticEngine()
            
            engine?.resetHandler = { [weak self] in
                guard let self else { return }
                self.log.debug("Reset handler: Restarting the engine.")
                
                DispatchQueue.main.async {
                    do {
                        try self.engine?.start()
                    } catch {
                        self.log.error("Failed to restart the engine. \(error)")
                    }
                }
            }
            
            engine?.stoppedHandler = { [weak self] reason in
                guard let self else { return }
                self.log.debug("Engine stop handler: Engine stopped for reason: \(reason.rawValue).")
                DispatchQueue.main.async {
                    switch reason {
                    case .applicationSuspended:
                        self.log.debug("App has been suspended.")
                    case .audioSessionInterrupt:
                        self.log.debug("Audio session has been interrupted.")
                    case .engineDestroyed:
                        self.log.debug("Engine has been destroyed")
                    case .idleTimeout:
                        self.log.debug("Engine idle timeout")
                    case .notifyWhenFinished:
                        self.log.debug("Engine notify when finished.")
                    case .systemError:
                        // TODO: I don't know if this is the place for this logic.
                        self.log.debug("Engine stopped due to system error.")
                        repeat {
                            do {
                                self.log.debug("Restart attempt \(self.restartAttempts).")
                                try self.engine?.start()
                            } catch {
                                self.log.debug("Failed to restart haptics. \(self.maxRestartAttempts - self.restartAttempts) attempts left.")
                                self.restartAttempts += 1
                            }
                        } while self.restartAttempts < self.maxRestartAttempts
                        if self.restartAttempts == self.maxRestartAttempts {
                            // according to the docs this is fine to do if the engine doesn't restart.
                            fatalError("Failed to start haptics.")
                        }
                    case .gameControllerDisconnect:
                        self.log.debug("Game controller disconnected.")
                    @unknown default:
                        self.log.debug("Engine has stopped for some unknown reason.")
                    }
                }
            }
        } catch {
            log.error("Failed to create haptic engine. \(error)")
        }
    }
}

extension HapticsManager {
    /// Creates and plays a success haptic.
    func correctAnswerHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            log.debug("The device doesn't support haptics.")
            audioManager.playSound(.correctAnswer)
            return
        }
        log.debug("Creating questions success haptic.")
        var events = [CHHapticEvent]()
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)

        guard let url = Bundle.main.url(forResource: "correct-choice", withExtension: "wav") else {
            log.error("Failed to find audio path.")
            return
        }
        
        do {
            let audioID = try engine?.registerAudioResource(url)
            guard let audioID else {
                log.error("Invalid audio id.")
                return
            }
            let audio = CHHapticEvent(audioResourceID: audioID, parameters: [.init(parameterID: .audioVolume, value: 0.7)], relativeTime: 0)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            events.append(event)
            events.append(audio)

            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
            log.debug("Successfully played the question success haptic.")
        } catch {
            log.error("Failed to play question success haptic. \(error)")
        }
    }
    
    /// Creates and plays a basic haptic.
    func buttonPressHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            log.debug("The device doesn't support haptics.")
            audioManager.playSound(.defaultButton)
            return
        }
        log.debug("Creating questions success haptic.")
        var events = [CHHapticEvent]()
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.25)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
            log.debug("Successfully played the answer selection haptic.")
        } catch {
            log.error("Failed to play answer selection haptic. \(error)")
        }
    }
    
    /// Plays haptics when the trivia round is over
    func triviaOverHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            log.debug("Device doesn't support haptics. Playing audio instead.")
            audioManager.playSound(.triviaRoundComplete)
            return
        }
        log.debug("Creating trivia over haptic.")
        var events = [CHHapticEvent]()
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
        guard let url = Bundle.main.url(forResource: AudioManager.AudioFile.triviaRoundComplete.filename, withExtension: AudioManager.AudioFile.triviaRoundComplete.extension) else {
            log.error("Failed to get audio url.")
            return
        }
        
        do {
            guard let audioID = try engine?.registerAudioResource(url) else {
                log.error("Failed to register audio resource.")
                return
            }
            let audioEvent = CHHapticEvent(audioResourceID: audioID, parameters: [], relativeTime: 0)
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.6)
            events.append(event)
            events.append(audioEvent)
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
            log.debug("Successfully played the trivia over haptic.")
        } catch {
            log.error("Failed to play trivia over  haptic. \(error)")
        }
    }
    
    /// Attempts to restart the haptic engine
    func restartEngine() {
        do {
            try engine?.start()
        } catch {
            log.error("Failed to restart haptic engine. \(error)")
        }
    }
}
