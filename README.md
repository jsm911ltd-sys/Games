Games - Roblox Dev Starter

Quick Start

- Install tools (Rokit recommended):
  - Install Rokit, then run: `rokit install`
- Install dependencies: `rokit run wally install` (or `wally install`)
- Start Rojo server: `rokit run rojo serve default.project.json`
- In Studio, use the Rojo plugin to connect to the server.

What's Included

- Rojo project mapping (`default.project.json`) for client, server, shared, and packages.
- Wally dependencies with wrappers under `Packages/` and `ServerPackages/`.
- Tool pinning via `rokit.toml` (Rojo, Wally, types).
- Formatting (`stylua.toml`) and lint config (`selene.toml`).
- VS Code tasks and settings for sourcemaps and formatting.

Project Layout

- `src/client`: Client scripts. Entry at `src/client/init.client.luau` loads `Controllers` if present.
- `src/server`: Server scripts. Entry at `src/server/init.server.luau` loads `Services` if present.
- `src/shared`: Shared modules available to both client and server.
- `src/replicatedFirst`: Reserved for first-load scripts; currently empty (no custom loader).
- `Packages/` and `ServerPackages/`: Wally-installed dependencies (mapped via Rojo).

Runtime Behavior

- Default Roblox loading screen is used; no custom UI is mounted in `ReplicatedFirst`.
- The Loader package auto-loads descendants under `Controllers` (client) and `Services` (server) if those folders exist.

Notes

- Fusion is installed and ready via `game.ReplicatedStorage.Packages.Fusion`.
- Server packages are mapped to `ServerStorage.ServerPackages` (safe from auto-execution).

Troubleshooting

- Loader wrapper name: If `Loader` is not found under `ReplicatedStorage.Packages`, ensure Wally installed wrappers exist as either `Loader` or `loader` to match `wally.toml`.
