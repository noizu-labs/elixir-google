# AGENTS.md — elixir-google

Guidance for coding agents (Grok, Codex, Claude, Cursor). Monorepo ops → `../../../../../CLAUDE.md` (trl-infra root).

## Identity

Elixir Google API client for Noizu apps (Google-surface integrations; pairs with `ai/elixir-google-mcp`). API-contract lib — align with live Google API surface.

## Stack & Commands

Elixir. `mix deps.get && mix compile`; `mix test`; `mix format`, `mix credo`.

## Universal Rules (compressed)

- **Trinity Protocol REQUIRED**: Orientation → Friction → Response (full text: monorepo `protocols/the-trinity-protocol.md`).
- **No shell in main thread** — delegate to taskers.
- **Worktrees**: all work on worktrees; `epic.<group>` consolidation branches off `develop`; squash-PR provenance into epics.
- MAIN checkout owns `deps/_build`; worktrees symlink deps (absolute path).
