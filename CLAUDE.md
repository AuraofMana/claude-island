# Claude Island (Fork)

Personal fork of Claude Island, a macOS notch overlay for monitoring Claude Code sessions. Five custom features added on top of upstream v1.2.

## Key Files

| File | What |
|------|------|
| `ClaudeIsland/` | Swift/SwiftUI source |
| `ClaudeIsland.xcodeproj` | Xcode project |
| `STATUS.md` | Living status with bug tracker and feature details |

## Custom Features

1. **Instance Rename** — right-click context menu, UserDefaults persistence
2. **Rich Permission Context** — closed notch shows "Bash: ls -la" instead of just icons
3. **Per-Event-Type Sounds** — 4 types with independent pickers + cooldown manager
4. **Draggable Tab Position** — horizontal drag along top edge, persisted offset
5. **Hotkeys** — Cmd+Opt+I toggle, Y/N/E in panel, optional direct-action shortcuts

## Current State

All 5 features implemented in code (branch `ben/custom-features`, commit f262f81, 551 insertions across 13 files). Not yet build-tested because Xcode is not installed.

3 known bugs documented in STATUS.md (click-through fix applied but untested, stale permission badge, AskUserQuestion not visible).

## Architecture Notes

- `ClaudeSessionMonitor` promoted to singleton (required for HotKeyManager)
- `SoundSelector` refactored for multiple pickers (expandedPickerKey pattern)
- Drag is horizontal/top-edge-only (full four-edge would require rotating UI)
- Two new files need adding to Xcode project navigator: `SoundCooldownManager.swift`, `HotKeyManager.swift`

## Repo

Personal repo: `AuraofMana/claude-island`. Upstream: `farouqaldori/claude-island`.
Push via HTTPS (SSH key is benlu-pm only): `gh auth switch --user AuraofMana` first.
