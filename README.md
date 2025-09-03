Games – Roblox Dev Starter

Quick start

- Install tools (Rokit recommended):
  - Install Rokit, then run: `rokit install`
- Install dependencies: `rokit run wally install` (or `wally install`)
- Start Rojo server: `rokit run rojo serve default.project.json`
- In Studio, use the Rojo plugin to connect to the server.

What’s included

- Rojo project mapping (`default.project.json`) for client, server, shared, and packages.
- Wally dependencies with wrappers under `Packages/` and `ServerPackages/`.
- Tool pinning via `rokit.toml` (Rojo, Wally, types).
- Formatting (`stylua.toml`) and lint config (`selene.toml`).
- VS Code tasks and settings for sourcemaps and formatting.

Notes

- Fusion is installed and ready via `game.ReplicatedStorage.Packages.Fusion`.
- Server packages are mapped to `ServerStorage.ServerPackages` (safe from auto-execution).
- ReplicatedFirst no longer overrides the default Roblox loading screen.

