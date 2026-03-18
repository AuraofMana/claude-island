//
//  SoundPickerRow.swift
//  ClaudeIsland
//
//  Notification sound selection picker for settings menu.
//  Supports per-event-type sound configuration.
//

import AppKit
import SwiftUI

struct SoundPickerRow: View {
    @ObservedObject var soundSelector: SoundSelector
    let eventType: SoundEventType?
    @State private var isHovered = false
    @State private var selectedSound: NotificationSound

    /// Backwards-compatible init (global sound, no event type)
    init(soundSelector: SoundSelector) {
        self.soundSelector = soundSelector
        self.eventType = nil
        self._selectedSound = State(initialValue: AppSettings.notificationSound)
    }

    /// Per-event-type init
    init(soundSelector: SoundSelector, eventType: SoundEventType) {
        self.soundSelector = soundSelector
        self.eventType = eventType
        self._selectedSound = State(initialValue: AppSettings.soundForEvent(eventType))
    }

    private var expandedKey: String {
        eventType?.rawValue ?? "global"
    }

    private var isExpanded: Bool {
        soundSelector.expandedPickerKey == expandedKey
    }

    private func setExpanded(_ value: Bool) {
        soundSelector.expandedPickerKey = value ? expandedKey : nil
    }

    private var label: String {
        eventType?.rawValue ?? "Notification Sound"
    }

    private var icon: String {
        eventType?.icon ?? "speaker.wave.2"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main row - shows current selection
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    setExpanded(!isExpanded)
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundColor(textColor)
                        .frame(width: 16)

                    Text(label)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(textColor)

                    Spacer()

                    Text(selectedSound.rawValue)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                        .lineLimit(1)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isHovered ? Color.white.opacity(0.08) : Color.clear)
                )
            }
            .buttonStyle(.plain)
            .onHover { isHovered = $0 }

            // Expanded sound list
            if isExpanded {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(NotificationSound.allCases, id: \.self) { sound in
                            SoundOptionRowInline(
                                sound: sound,
                                isSelected: selectedSound == sound
                            ) {
                                // Play preview sound
                                if let soundName = sound.soundName {
                                    NSSound(named: soundName)?.play()
                                }
                                selectedSound = sound
                                if let eventType = eventType {
                                    AppSettings.setSoundForEvent(eventType, sound: sound)
                                } else {
                                    AppSettings.notificationSound = sound
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: CGFloat(min(NotificationSound.allCases.count, 6)) * 32)
                .padding(.leading, 28)
                .padding(.top, 4)
            }
        }
        .onAppear {
            if let eventType = eventType {
                selectedSound = AppSettings.soundForEvent(eventType)
            } else {
                selectedSound = AppSettings.notificationSound
            }
        }
    }

    private var textColor: Color {
        .white.opacity(isHovered ? 1.0 : 0.7)
    }
}

// MARK: - Sound Option Row (Inline version)

private struct SoundOptionRowInline: View {
    let sound: NotificationSound
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(isSelected ? TerminalColors.green : Color.white.opacity(0.2))
                    .frame(width: 6, height: 6)

                Text(sound.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(isHovered ? 1.0 : 0.7))

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(TerminalColors.green)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color.white.opacity(0.06) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
