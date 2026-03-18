//
//  SoundSelector.swift
//  ClaudeIsland
//
//  Manages sound selection state for the settings menu
//

import Combine
import Foundation

@MainActor
class SoundSelector: ObservableObject {
    static let shared = SoundSelector()

    // MARK: - Published State

    /// Which picker is currently expanded (by key), or nil if none
    @Published var expandedPickerKey: String? = nil

    /// Legacy compatibility: whether any picker is expanded
    var isPickerExpanded: Bool {
        get { expandedPickerKey != nil }
        set { expandedPickerKey = newValue ? "global" : nil }
    }

    // MARK: - Constants

    /// Maximum number of sound options to show before scrolling
    private let maxVisibleOptions = 6

    /// Height per sound option row
    private let rowHeight: CGFloat = 32

    private init() {}

    // MARK: - Public API

    /// Extra height needed when any picker is expanded (capped for scrolling)
    var expandedPickerHeight: CGFloat {
        guard expandedPickerKey != nil else { return 0 }
        let totalOptions = NotificationSound.allCases.count
        let visibleOptions = min(totalOptions, maxVisibleOptions)
        return CGFloat(visibleOptions) * rowHeight + 8 // +8 for padding
    }
}
