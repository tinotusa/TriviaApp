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
    func questionSuccessHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            log.debug("The device doesn't support haptics.")
            return
        }
        log.debug("Creating questions success haptic.")
        var events = [CHHapticEvent]()
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
            log.debug("Successfully played the question success haptic.")
        } catch {
            log.error("Failed to play question success haptic. \(error)")
        }
    }
    
    /// Creates and plays a success haptic.
    func answerSelectionHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            log.debug("The device doesn't support haptics.")
            return
        }
        log.debug("Creating questions success haptic.")
        var events = [CHHapticEvent]()
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.2)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        
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
    
    /// Attempts to restart the haptic engine
    func restartEngine() {
        do {
            try engine?.start()
        } catch {
            log.error("Failed to restart haptic engine. \(error)")
        }
    }
}
