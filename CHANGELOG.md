# Changelog

## Unreleased

### Orchestrator repo (`backend/`)

- Add Docker Compose orchestration to start PostgreSQL + `uav_telemetry` + `uav-media-info` with bind-mounted source for easy upgrades.
- Add DB bootstrap schema at `db-docker/init/001_schema.sql` and keep Postgres bound to `127.0.0.1:${POSTGRES_PORT}` for safety.
- Add dev Dockerfiles under `docker/` that only install dependencies (code is mounted at runtime).
- Centralize runtime configuration into root `.env` (template: `.env.example`):
  - `POSTGRES_*` for DB
  - `TELEMETRY_PORT` / `MEDIA_PORT` for host ports
  - Optional `ZLM_HOST` / `ZLM_SECRET` (no hardcoded secrets in compose)
- Document end-to-end setup and operational workflows in `README.md` (submodules, compose, external access).

Relevant orchestrator commits:
- `773c93f` initial orchestrator repo
- `39d352d` comment out unused ZLM env vars in compose
- `0d03bd3` centralize env config (root `.env.example`, port/ZLM wiring)
- `3cfcbd1` docs: update env file references
- `02fc859` docs: set default `ZLM_HOST` in env example

### Submodules

#### `uav-media-info`

- Stop creating a module-level `ZLMService` singleton (keeps wrapper for future integration without implicit import-time binding).

Relevant submodule commit:
- `ad023b5` chore: disable unused zlm_service singleton

#### `uav_telemetry`

- No orchestrator-side code changes made directly inside the submodule in this session; the orchestrator tracks the submodule pointer.

