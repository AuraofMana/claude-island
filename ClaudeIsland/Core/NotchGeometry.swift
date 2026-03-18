//
//  NotchGeometry.swift
//  ClaudeIsland
//
//  Geometry calculations for the notch
//

import CoreGraphics
import Foundation

/// Pure geometry calculations for the notch
struct NotchGeometry: Sendable {
    let deviceNotchRect: CGRect
    let screenRect: CGRect
    let windowHeight: CGFloat
    let horizontalOffset: CGFloat

    init(deviceNotchRect: CGRect, screenRect: CGRect, windowHeight: CGFloat, horizontalOffset: CGFloat = 0) {
        self.deviceNotchRect = deviceNotchRect
        self.screenRect = screenRect
        self.windowHeight = windowHeight
        self.horizontalOffset = horizontalOffset
    }

    /// The notch rect in screen coordinates (for hit testing with global mouse position)
    var notchScreenRect: CGRect {
        CGRect(
            x: screenRect.midX - deviceNotchRect.width / 2 + horizontalOffset,
            y: screenRect.maxY - deviceNotchRect.height,
            width: deviceNotchRect.width,
            height: deviceNotchRect.height
        )
    }

    /// The opened panel rect in screen coordinates for a given size
    func openedScreenRect(for size: CGSize) -> CGRect {
        // Match the actual rendered panel size (tuned to match visual output)
        let width = size.width - 6
        let height = size.height - 30

        // Clamp the panel so it stays on screen
        let idealX = screenRect.midX - width / 2 + horizontalOffset
        let clampedX = max(screenRect.minX + 4, min(idealX, screenRect.maxX - width - 4))

        return CGRect(
            x: clampedX,
            y: screenRect.maxY - height,
            width: width,
            height: height
        )
    }

    /// Check if a point is in the notch area (with padding for easier interaction)
    func isPointInNotch(_ point: CGPoint) -> Bool {
        notchScreenRect.insetBy(dx: -10, dy: -5).contains(point)
    }

    /// Check if a point is in the opened panel area
    func isPointInOpenedPanel(_ point: CGPoint, size: CGSize) -> Bool {
        openedScreenRect(for: size).contains(point)
    }

    /// Check if a point is outside the opened panel (for closing)
    func isPointOutsidePanel(_ point: CGPoint, size: CGSize) -> Bool {
        !openedScreenRect(for: size).contains(point)
    }

    /// Maximum horizontal offset so the notch stays on screen
    var maxOffset: CGFloat {
        screenRect.width / 2 - deviceNotchRect.width / 2 - 10
    }

    /// Create a new geometry with a different offset (for drag updates)
    func withOffset(_ offset: CGFloat) -> NotchGeometry {
        let clamped = max(-maxOffset, min(offset, maxOffset))
        return NotchGeometry(
            deviceNotchRect: deviceNotchRect,
            screenRect: screenRect,
            windowHeight: windowHeight,
            horizontalOffset: clamped
        )
    }
}
