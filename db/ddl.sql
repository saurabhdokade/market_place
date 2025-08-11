
---

### `db/ddl.sql`
```sql
-- ddl.sql (PostgreSQL)

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username VARCHAR(255) NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role VARCHAR(50) NOT NULL CHECK (role IN ('admin','user')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_users_username ON users (username);

-- objects table
CREATE TABLE IF NOT EXISTS objects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NULL,
  data JSONB NOT NULL,
  deleted BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_objects_name ON objects (name);
CREATE INDEX IF NOT EXISTS idx_objects_not_deleted ON objects (name) WHERE deleted = false;
CREATE INDEX IF NOT EXISTS idx_objects_data_gin ON objects USING GIN (data jsonb_path_ops);

-- object_versions table
CREATE TABLE IF NOT EXISTS object_versions (
  version_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  object_id UUID NOT NULL,
  data JSONB NOT NULL,
  version_timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT fk_object_versions_object FOREIGN KEY (object_id)
    REFERENCES objects (id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_object_versions_object_id ON object_versions (object_id);

-- api_logs table
CREATE TABLE IF NOT EXISTS api_logs (
  log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  endpoint TEXT NOT NULL,
  method VARCHAR(10) NOT NULL,
  status_code INTEGER,
  request_timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
  user_id UUID NULL,
  meta JSONB NULL,
  CONSTRAINT fk_api_logs_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_api_logs_user_id ON api_logs (user_id);
CREATE INDEX IF NOT EXISTS idx_api_logs_endpoint_ts ON api_logs (endpoint, request_timestamp);


