//
//  Settings.swift
//  ClaudeIsland
//
//  App settings manager using UserDefaults
//

import Foundation

/// Available notification sounds
enum NotificationSound: String, CaseIterable {
    case none = "None"
    case pop = "Pop"
    case ping = "Ping"
    case tink = "Tink"
    case glass = "Glass"
    case blow = "Blow"
    case bottle = "Bottle"
    case frog = "Frog"
    case funk = "Funk"
    case hero = "Hero"
    case morse = "Morse"
    case purr = "Purr"
    case sosumi = "Sosumi"
    case submarine = "Submarine"
    case basso = "Basso"

    /// The system sound name to use with NSSound, or nil for no sound
    var soundName: String? {
        self == .none ? nil : rawValue
    }
}

/// Categories of events that can trigger distinct notification sounds
enum SoundEventType: String, CaseIterable {
    case taskComplete = "Task Complete"
    case needsPermission = "Needs Permission"
    case askingQuestion = "Asking Question"
    case error = "Error"

    /// SF Symbol icon for display in settings
    var icon: String {
        switch self {
        case .taskComplete: return "checkmark.circle"
        case .needsPermission: return "hand.raised"
        case .askingQuestion: return "questionmark.bubble"
        case .error: return "exclamationmark.triangle"
        }
    }
}

enum AppSettings {
    private static let defaults = UserDefaults.standard

    // MARK: - Keys

    private enum Keys {
        static let notificationSound = "notificationSound"
        static let sessionAliases = "sessionAliases"
    }

    // MARK: - Notification Sound

    /// The sound to play when Claude finishes and is ready for input
    static var notificationSound: NotificationSound {
        get {
            guard let rawValue = defaults.string(forKey: Keys.notificationSound),
                  let sound = NotificationSound(rawValue: rawValue) else {
                return .pop // Default to Pop
            }
            return sound
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.notificationSound)
        }
    }

    // MARK: - Per-Event-Type Sounds

    /// Get the sound for a specific event type
    static func soundForEvent(_ type: SoundEventType) -> NotificationSound {
        let key = "sound_\(type.rawValue)"
        guard let raw = defaults.string(forKey: key),
              let sound = NotificationSound(rawValue: raw) else {
            return defaultSound(for: type)
        }
        return sound
    }

    /// Set the sound for a specific event type
    static func setSoundForEvent(_ type: SoundEventType, sound: NotificationSound) {
        defaults.set(sound.rawValue, forKey: "sound_\(type.rawValue)")
    }

    /// Default sounds per event type
    private static func defaultSound(for type: SoundEventType) -> NotificationSound {
        switch type {
        case .taskComplete: return .pop
        case .needsPermission: return .glass
        case .askingQuestion: return .ping
        case .error: return .basso
        }
    }

    // MARK: - Hotkey Mode

    /// Whether direct-action hotkeys are enabled (Cmd+Opt+Y/N without opening panel)
    static var directActionHotkeys: Bool {
        get { defaults.bool(forKey: "directActionHotkeys") }
        set { defaults.set(newValue, forKey: "directActionHotkeys") }
    }

    // MARK: - Notch Position

    /// Horizontal offset from center for the notch tab (0 = centered, negative = left, positive = right)
    static var notchOffsetX: CGFloat {
        get { CGFloat(defaults.double(forKey: "notchOffsetX")) }
        set { defaults.set(Double(newValue), forKey: "notchOffsetX") }
    }

    // MARK: - Session Aliases

    /// User-defined display names for sessions, keyed by sessionId
    static var sessionAliases: [String: String] {
        get {
            defaults.dictionary(forKey: Keys.sessionAliases) as? [String: String] ?? [:]
        }
        set {
            defaults.set(newValue, forKey: Keys.sessionAliases)
        }
    }

    /// Set or clear an alias for a session
    static func setAlias(_ alias: String?, for sessionId: String) {
        var aliases = sessionAliases
        if let alias = alias, !alias.isEmpty {
            aliases[sessionId] = alias
        } else {
            aliases.removeValue(forKey: sessionId)
        }
        sessionAliases = aliases
    }

    /// Get the alias for a session, if one exists
    static func alias(for sessionId: String) -> String? {
        sessionAliases[sessionId]
    }
}
