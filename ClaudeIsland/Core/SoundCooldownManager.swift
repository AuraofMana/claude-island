//
//  SoundCooldownManager.swift
//  ClaudeIsland
//
//  Prevents notification sound spam by enforcing cooldowns between events
//

import Foundation

@MainActor
class SoundCooldownManager {
    static let shared = SoundCooldownManager()

    private var lastSoundTime: [SoundEventType: Date] = [:]

    /// Global cooldown between any two sounds (seconds)
    private let globalCooldown: TimeInterval = 3

    /// Suppress question/permission sounds within this window after a task complete (seconds)
    private let postCompleteSuppression: TimeInterval = 10

    private init() {}

    /// Whether a sound should play for the given event type
    func shouldPlay(_ type: SoundEventType) -> Bool {
        let now = Date()

        // Don't play question/permission sound shortly after task complete
        if type == .askingQuestion || type == .needsPermission {
            if let lastComplete = lastSoundTime[.taskComplete],
               now.timeIntervalSince(lastComplete) < postCompleteSuppression {
                return false
            }
        }

        // Global cooldown: no two sounds within 3 seconds
        for (_, time) in lastSoundTime {
            if now.timeIntervalSince(time) < globalCooldown {
                return false
            }
        }

        return true
    }

    /// Record that a sound was played
    func recordPlayed(_ type: SoundEventType) {
        lastSoundTime[type] = Date()
    }
}
