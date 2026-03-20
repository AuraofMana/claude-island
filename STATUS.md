# Claude Island (Fork) — Status

**Started:** 2026-03-18
**Last updated:** 2026-03-19

## What This Is
Personal fork of Claude Island (macOS notch overlay for monitoring Claude Code sessions). Five custom features added on top of upstream v1.2.

## Current State
All 5 features implemented in code on branch `ben/custom-features` (commit f262f81, 551 insertions across 13 files). **Not yet build-tested** because Xcode is not installed on this machine.

Features:
1. Instance Rename (right-click context menu, UserDefaults persistence)
2. Rich Permission Context (closed notch shows "Bash: ls -la" instead of just icons)
3. Per-Event-Type Sounds (4 types with independent pickers + cooldown manager)
4. Draggable Tab Position (horizontal drag along top edge, persisted offset)
5. Hotkeys (Cmd+Opt+I toggle, Y/N/E in panel, optional direct-action Cmd+Opt+Y/N)

## What's Next
- Install Xcode and build the project
- Add 2 new files to Xcode project navigator: `SoundCooldownManager.swift`, `HotKeyManager.swift`
- Fix any compile errors (written without build verification)
- Test all 5 features with live Claude Code sessions
- Test multi-monitor for drag feature
- Windows support deferred (would need a separate Tauri/Electron app)

## Known Bugs (to fix after initial build-test)

### Bug 1: Stale permission badge after terminal approval
When you approve a tool in the terminal, Claude Island keeps showing the "needs approval" state until the tool finishes executing (`PostToolUse` hook fires). For long-running tools (10+ min bash commands), this means a stale badge for the entire duration.

**Root cause:** `ClaudeSessionMonitor.swift:61-63` only cancels pending permissions on `PostToolUse`. No hook fires between "user approves in terminal" and "tool finishes." The socket Claude Island is holding stays open because the hook script is still alive.

**Fix:** Add a `DispatchSourceTimer` in `HookSocketServer.swift` that activates only when `pendingPermissions` is non-empty. Every 1.5s, `poll()` each pending socket for `POLLHUP/POLLERR`. If the socket is dead (Claude Code moved on), cancel that permission immediately. Timer deactivates when no permissions are pending. Near-zero CPU cost.

### Bug 2: AskUserQuestion not visible in Claude Island
When Claude asks a yes/no or multiple-choice question (`AskUserQuestion` tool), Claude Island shows no indication. The user only sees it in the terminal. Claude Island may show "processing" briefly, but never shows "waiting for your answer."

**Root cause:** `AskUserQuestion` is a regular tool call, not a `PermissionRequest` hook event. No `waiting_for_approval` status fires for it, so Claude Island never enters the attention-needed state.

**Fix:** Extend `JSONLInterruptWatcher.swift` (already watches the JSONL via `DispatchSource`, zero-cost file system events) to detect `"AskUserQuestion"` tool_use blocks. Add a new delegate method `didDetectUserQuestion(sessionId:)`. Wire through `ClaudeSessionMonitor` to `SessionStore` to set a `.waitingForQuestion` phase. Render with distinct visual (e.g., "?" icon instead of permission shield).

## Context / Decisions Made
- **Fork, not contribute first:** 5 opinionated features, upstream has 20 open PRs already. Build on fork, upstream the general-purpose ones later.
- **Personal repo (AuraofMana), not work (benlu-pm):** This is a personal productivity tool, not DoorDash work.
- **Mac only for now:** Claude Island is pure Swift/SwiftUI. Cross-platform would be a rewrite.
- **ClaudeSessionMonitor promoted to singleton:** Required for HotKeyManager to access approve/deny. Breaking change if upstream merges differently.
- **SoundSelector refactored:** `isPickerExpanded: Bool` replaced with `expandedPickerKey: String?` to support multiple pickers (one per event type). Backward-compatible via computed property.
- **Drag is top-edge-only:** Full four-edge drag would require rotating UI and redrawing NotchShape. Horizontal-only covers 90% of the use case.
- **Remote config:** SSH key is tied to benlu-pm. Push to AuraofMana via HTTPS with `gh auth switch --user AuraofMana` first.
