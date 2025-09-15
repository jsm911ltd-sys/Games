# Stepping Platforms – Full Plan & Checklist

A practical, checkable plan to ship the “stepping platforms” ability. Use this as the single source of truth. Check items off as you complete them.

Owner: ________    |    Start: ________    |    Target Beta: ________

## File Map (planned)
- [ ] Client entry: `src/client/init.client.luau`
- [ ] Ability controller: `src/client/Abilities/SteppingController.luau`
- [ ] Step planner: `src/client/Abilities/StepPlanner.luau`
- [ ] Ghost/preview visuals: `src/client/Abilities/StepGhost.luau`
- [ ] Shared placement math: `src/shared/PlacementSolver.luau`
- [ ] Shared config: `src/shared/StepConfig.luau`
- [ ] Remotes: `src/shared/Remotes.luau`
- [ ] Server spawner: `src/server/StepSpawner.server.luau`
- [ ] Server pool: `src/server/StepPool.server.luau`
- [ ] Server validation: `src/server/StepValidation.server.luau`
- [ ] VFX/SFX: `src/client/Abilities/StepVfx.luau`
- [ ] UI (stamina/combo): `src/client/UI/StepHud.luau`
- [ ] Debug HUD: `src/client/Debug/StepDebugHud.luau`

---

## Milestone 0 — Foundations
- [ ] Confirm project boots in Studio with Rojo plugin
- [ ] Agree on coding style (Luau type coverage level)
- [ ] Create folders per File Map (no logic yet)
- [ ] Add blank modules with exports and TODO headers
- [ ] Add central `StepConfig` defaults (sizes, timing, costs)

Acceptance: Project runs; all modules require() without errors; config values readable from client and server.

## Milestone 1 — Input & Ability State (Client)
- [ ] Capture Space press/hold + movement intent in `SteppingController`
- [ ] Implement state machine: Idle → Primed → Stepping → Cooldown; Blocked
- [ ] Foot cadence detection (estimate stride from `Humanoid.MoveDirection` and speed)
- [ ] Buffer presses for short grace window (e.g., 120ms)
- [ ] Disable in restricted states (seated, ragdolled, swimming)

Acceptance: Press Space while moving: state transitions visible via debug prints/HUD; no runtime errors.

## Milestone 2 — Step Prediction (Client)
- [ ] Implement `StepPlanner.getNextFootPose(character, velocity, camera)`
- [ ] Compute step length from speed with min/max clamps
- [ ] Raycast for clearance and surface normal; fallback to free-space if no ground
- [ ] Determine which foot is next and offset lateral placement
- [ ] Expose debug draw of predicted pose

Acceptance: Predicted pose matches running direction; debug footprint appears ahead and alternates feet.

## Milestone 3 — Networking & Messaging
- [ ] Define `Remotes.RequestStep` (client→server) and `Remotes.StepCreated` (server→clients)
- [ ] Define payload schema: { playerId, desiredCFrame, timestamp, speed } (client) / { stepId, cframe, owner } (server)
- [ ] Implement light client prediction: spawn local ghost immediately
- [ ] Reconcile on server response (snap or lerp ghost to authoritative pose)
- [ ] Assign network ownership to player for spawned step

Acceptance: Client can request a step; server echoes creation; ghost reconciles within 100–150ms smoothly.

## Milestone 4 — Server Spawner & Pool
- [ ] Implement `StepPool` with preallocated Parts (size/material from config)
- [ ] Implement `StepSpawner.spawn(request)` that reserves from pool and positions part
- [ ] Add cleanup: release to pool on lifetime expiry or owner death/teleport
- [ ] Track per-player active steps for quick cleanup and limits

Acceptance: Server can spawn, reuse, and despawn steps without creating/destroying instances repeatedly under normal usage.

## Milestone 5 — Validation & Anti‑Exploit (Server)
- [ ] Validate requested pose within distance, height, and map bounds
- [ ] Check line-of-sight from character to target pose (raycast)
- [ ] Enforce rate limits: steps/sec, max burst, cooldown
- [ ] Deny when character in restricted states
- [ ] Log denial reasons to debug channel

Acceptance: Malformed or spammy requests are denied; valid ones pass; denial reasons visible in logs.

## Milestone 6 — Platform Behavior & Physics
- [ ] Define trajectory: fly-in from source (backpack/orbit) to pose
- [ ] On arrival: temporarily CanCollide true for owner, non-collidable for others
- [ ] Configure material, friction, density; anchor or lightly constrain after landing
- [ ] Implement lifetime + fade-out; release to pool
- [ ] Handle moving bases: weld/parent if landing on moving platform

Acceptance: Platform flies in, supports owner briefly, then fades/despawns; others can’t be blocked.

## Milestone 7 — Visuals, Audio, and Feel
- [ ] Trail from source to step; color/intensity scales with speed/combo
- [ ] Landing puff or ripple VFX; subtle camera kick
- [ ] Ghost preview with translucency and aim direction arrow
- [ ] SFX: summon, land, dissolve; pitch rises with combo

Acceptance: Visuals/audio clearly communicate timing and success without clutter.

## Milestone 8 — UI & Resources
- [ ] Add stamina/heat resource that increases per step; regenerates over time
- [ ] Display meter in `StepHud` with thresholds and overheat state
- [ ] Combo counter with “perfect” timing window indicators
- [ ] Mobile and controller bindings (on-screen button / gamepad)

Acceptance: Resource limits the ability; UI reflects state and prevents spam.

## Milestone 9 — Config & Variants
- [ ] Centralize tunables in `StepConfig` with comments and sensible defaults
- [ ] Variant archetypes: speed, distance, stickiness (optional)
- [ ] Feature flags to enable/disable variants at runtime

Acceptance: Designers can tune numbers without code changes; variants toggleable.

## Milestone 10 — Edge Cases & Rules
- [ ] Airborne chain: allow N steps mid-air with stricter validation
- [ ] Slopes: clamp max surface angle; adjust hip height/foot IK bias
- [ ] Water: disable or float variant; clear feedback when disabled
- [ ] Streaming: fallback if target is outside streamed region

Acceptance: Edge cases behave predictably; no hard errors.

## Milestone 11 — Performance & Limits
- [ ] Pool sizes based on target CCU and step lifetimes
- [ ] Per-player and global active step caps
- [ ] LOD on VFX; throttle effect spawn on low FPS
- [ ] Minimal remote payloads; avoid per-heartbeat spam

Acceptance: Stable frame times and memory under load; GC churn minimal.

## Milestone 12 — Debug & Telemetry
- [ ] Debug HUD: state machine, cadence, next foot, predicted pose
- [ ] Toggle draw rays and footprints via keybind or command
- [ ] Telemetry counters: steps created, denied, average chain length, falls after use
- [ ] Optional A/B toggles: cooldowns, stamina curves, perfect-window size

Acceptance: Engineers can diagnose issues quickly; data available for tuning.

## Milestone 13 — Testing & QA
- [ ] Solo sandbox scenarios with scripted routes and gaps
- [ ] Latency simulation (100–200ms) to validate prediction smoothness
- [ ] Load test: bots or scripts to push per-player/global caps
- [ ] Regression checklist for map changes (collisions, streaming boundaries)

Acceptance: Pass rate meets threshold; no blockers; documented known issues.

## Milestone 14 — Ship Checklist
- [ ] Feature-flag guard in place and default OFF
- [ ] Final tuning pass documented in `StepConfig`
- [ ] Content review: materials, SFX levels, seizure-safety
- [ ] QA sign-off and rollout plan (staged enable)
- [ ] Post-launch monitoring dashboard links

Acceptance: Flip flag to ON for a test server; metrics healthy; ready for wider rollout.

---

## Progress Log
- [ ] 00 — Plan created and agreed: ________
- [ ] 01 — Foundations complete: ________
- [ ] 02 — First playable (basic spawn, no VFX): ________
- [ ] 03 — Prediction + reconciliation stable: ________
- [ ] 04 — Anti-exploit and limits tuned: ________
- [ ] 05 — VFX/UI polish pass: ________
- [ ] 06 — Performance validated at target CCU: ________
- [ ] 07 — Ship: ________

---

## Notes
- Start with a single platform archetype; defer variants until after first playable.
- Keep server authoritative on actual platform spawning and validation.
- Use pooling early to avoid rework.

