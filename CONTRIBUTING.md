# Contributing

## Scope of this repo

This repository is an **orchestrator** (deployment + composition). Application code lives in submodules:

- `uav_telemetry`
- `uav-media-info`

## Changelog policy (best practice)

- For any user-visible change (ports, env vars, compose behavior, DB schema/init, deploy/run docs), update `CHANGELOG.md` under **[Unreleased]**.
- Keep entries short and actionable.
- Never include secrets (passwords, API keys, tokens). Prefer variable names (e.g. `POSTGRES_PASSWORD`).
- When cutting a release, move items from **[Unreleased]** to a new version section like `## [X.Y.Z] - YYYY-MM-DD`.

## Submodules

- Make code changes inside the relevant submodule repo and push there.
- In this orchestrator repo, commit the submodule pointer update (`git add uav_telemetry uav-media-info`).
