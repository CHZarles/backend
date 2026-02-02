-- Shared Postgres schema for both services:
-- - uav_telemetry: flight_records
-- - uav-media-info: video_recordings

BEGIN;

CREATE TABLE IF NOT EXISTS flight_records (
    record_id   BIGSERIAL PRIMARY KEY,
    drone_id    VARCHAR(64) NOT NULL,
    start_time  BIGINT NOT NULL,
    file_path   TEXT NOT NULL,
    device_type VARCHAR(64) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_flight_records_drone_start
    ON flight_records (drone_id, start_time DESC);

CREATE INDEX IF NOT EXISTS idx_flight_records_start_time
    ON flight_records (start_time);

CREATE TABLE IF NOT EXISTS video_recordings (
    record_id       BIGSERIAL PRIMARY KEY,
    stream_id       VARCHAR(128) NOT NULL,
    drone_id        VARCHAR(64) NOT NULL,
    file_path       TEXT NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMIT;
