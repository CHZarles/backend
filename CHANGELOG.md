# Changelog

All notable changes to this orchestrator repo should be documented in this file.

The format is based on Keep a Changelog, and this project aims to follow Semantic Versioning.

## [Unreleased]

### Added

### Changed

### Fixed

## [0.1.0] - 2026-02-02

### Added

- Docker Compose orchestration to start PostgreSQL + `uav_telemetry` + `uav-media-info` with bind-mounted source for easy upgrades.
- DB bootstrap schema at `db-docker/init/001_schema.sql` and Postgres bound to `127.0.0.1:${POSTGRES_PORT}` for safety.
- Dev Dockerfiles under `docker/` that only install dependencies (code is mounted at runtime).
- Root `.env` template (`.env.example`) for centralized runtime configuration:
  - `POSTGRES_*` for DB
  - `TELEMETRY_PORT` / `MEDIA_PORT` for host ports
  - Optional `ZLM_HOST` / `ZLM_SECRET` (no hardcoded secrets in compose)

### Changed

- README and operational docs updated to match the orchestrator/submodule workflow.

### Fixed

- Documentation references updated to consistently use the root `.env`.

### Notes

Relevant orchestrator commits:
- `773c93f` initial orchestrator repo
- `39d352d` comment out unused ZLM env vars in compose
- `0d03bd3` centralize env config (root `.env.example`, port/ZLM wiring)
- `3cfcbd1` docs: update env file references
- `02fc859` docs: set default `ZLM_HOST` in env example

Submodule notes (tracked via gitlink pointers in this repo):

- `uav-media-info`: stop creating a module-level `ZLMService` singleton (`ad023b5`)
- `uav_telemetry`: orchestrator tracks the submodule pointer; no direct edits were made inside this repo during this session

