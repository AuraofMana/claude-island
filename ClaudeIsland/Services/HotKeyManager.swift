//
//  HotKeyManager.swift
//  ClaudeIsland
//
//  Handles global keyboard shortcuts for the notch panel.
//  Two modes: panel-first (open panel, then Y/N/E) and direct-action (Cmd+Opt+Y/N).
//

import AppKit
import Combine
import Foundation

@MainActor
class HotKeyManager: ObservableObject {
    static let shared = HotKeyManager()

    // MARK: - Settings

    enum HotKeyMode: String {
        case panelFirst
        case directAction
    }

    @Published var mode: HotKeyMode = .panelFirst

    // MARK: - Key Codes

    // Virtual key codes for common keys
    private static let keyI: UInt16 = 34
    private static let keyY: UInt16 = 16
    private static let keyN: UInt16 = 45
    private static let keyE: UInt16 = 14

    // MARK: - Dependencies

    private weak var viewModel: NotchViewModel?
    private var cancellables = Set<AnyCancellable>()

    private init() {}

    // MARK: - Setup

    /// Wire up key event monitoring. Call once after viewModel is available.
    func attach(to viewModel: NotchViewModel) {
        self.viewModel = viewModel

        EventMonitors.shared.keyDown
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleKeyDown(event)
            }
            .store(in: &cancellables)
    }

    // MARK: - Key Handling

    private func handleKeyDown(_ event: NSEvent) {
        guard let viewModel = viewModel else { return }
        let sessionMonitor = ClaudeSessionMonitor.shared

        let hasCmd = event.modifierFlags.contains(.command)
        let hasOpt = event.modifierFlags.contains(.option)

        // Cmd+Opt+I: toggle panel
        if hasCmd && hasOpt && event.keyCode == Self.keyI {
            if viewModel.status == .opened {
                viewModel.notchClose()
            } else {
                viewModel.notchOpen(reason: .click)
            }
            return
        }

        // Direct-action mode: Cmd+Opt+Y/N approve/deny without opening panel
        if mode == .directAction && hasCmd && hasOpt {
            if event.keyCode == Self.keyY {
                approveFirst(sessionMonitor)
                return
            }
            if event.keyCode == Self.keyN {
                rejectFirst(sessionMonitor)
                return
            }
        }

        // When panel is open: Y/N/E keys (no modifiers required)
        if viewModel.status == .opened && !hasCmd && !hasOpt {
            switch event.keyCode {
            case Self.keyY:
                approveFirst(sessionMonitor)
            case Self.keyN:
                rejectFirst(sessionMonitor)
            case Self.keyE:
                expandToChat(viewModel, sessionMonitor)
            default:
                break
            }
        }
    }

    // MARK: - Actions

    private func approveFirst(_ monitor: ClaudeSessionMonitor) {
        guard let session = monitor.pendingInstances.first else { return }
        monitor.approvePermission(sessionId: session.sessionId)
    }

    private func rejectFirst(_ monitor: ClaudeSessionMonitor) {
        guard let session = monitor.pendingInstances.first else { return }
        monitor.denyPermission(sessionId: session.sessionId, reason: nil)
    }

    private func expandToChat(_ viewModel: NotchViewModel, _ monitor: ClaudeSessionMonitor) {
        // Open panel if closed
        if viewModel.status != .opened {
            viewModel.notchOpen(reason: .click)
        }
        // Switch to chat for the first pending session, or first session
        if let session = monitor.pendingInstances.first ?? monitor.instances.first {
            viewModel.showChat(for: session)
        }
    }
}
