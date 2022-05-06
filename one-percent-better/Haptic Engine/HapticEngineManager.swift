//
//  HapticEngineManager.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 1/3/22.
//

import Foundation

import CoreHaptics

class HapticEngineManager {
    
    /// A haptic engine manages the connection to the haptic server.
    private static var engine: CHHapticEngine? = {
        var engine: CHHapticEngine? = nil
        // Create and configure a haptic engine.
        do {
            // Associate the haptic engine with the default audio session
            // to ensure the correct behavior when playing audio-based haptics.
            //            let audioSession = AVAudioSession.sharedInstance()
            //            engine = try CHHapticEngine(audioSession: audioSession)
            engine = try CHHapticEngine()
        } catch let error {
            print("Engine Creation Error: \(error)")
        }
        
        guard let engine = engine else {
            print("Failed to create engine!")
            return nil
        }
        
        // The stopped handler alerts you of engine stoppage due to external causes.
        engine.stoppedHandler = { reason in
            print("The engine stopped for reason: \(reason.rawValue)")
            switch reason {
            case .audioSessionInterrupt:
                print("Audio session interrupt")
            case .applicationSuspended:
                print("Application suspended")
            case .idleTimeout:
                print("Idle timeout")
            case .systemError:
                print("System error")
            case .notifyWhenFinished:
                print("Playback finished")
            case .gameControllerDisconnect:
                print("Controller disconnected.")
            case .engineDestroyed:
                print("Engine destroyed.")
            @unknown default:
                print("Unknown error")
            }
        }
        
        // The reset handler provides an opportunity for your app to restart the engine in case of failure.
        engine.resetHandler = {
            // Try restarting the engine.
            print("The engine reset --> Restarting now!")
            do {
                try engine.start()
            } catch {
                print("Failed to restart the engine: \(error)")
            }
        }
        return engine
    }()
    
    static func shared() -> CHHapticEngine? {
        return engine
    }
    
    static func playHaptic(intensity: Float = 1.0) {
        guard let engine = engine else { return }
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [.init(parameterID: .hapticIntensity, value: intensity)], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            
            try engine.start()
            try player.start(atTime: 0)
        } catch let error {
            print("Error playing haptic sound: \(error)")
        }
    }
}
