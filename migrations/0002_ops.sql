CREATE TABLE IF NOT EXISTS agents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  token_hash TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'offline',
  last_seen_at TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS device_credentials (
  device_id INTEGER PRIMARY KEY,
  ssh_username TEXT,
  ssh_password_cipher TEXT,
  snmp_community_cipher TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS metrics (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  device_id INTEGER NOT NULL,
  metric TEXT NOT NULL,
  value REAL,
  unit TEXT,
  observed_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS device_backups (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  device_id INTEGER NOT NULL,
  filename TEXT NOT NULL,
  storage_key TEXT NOT NULL,
  checksum TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS alerts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  device_id INTEGER,
  severity TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT,
  status TEXT NOT NULL DEFAULT 'open',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  resolved_at TEXT,
  FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE SET NULL
);
CREATE TABLE IF NOT EXISTS jobs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  agent_id INTEGER,
  device_id INTEGER,
  type TEXT NOT NULL,
  payload TEXT,
  status TEXT NOT NULL DEFAULT 'queued',
  result TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  started_at TEXT,
  finished_at TEXT,
  FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE SET NULL,
  FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_jobs_status ON jobs(status, created_at);
CREATE INDEX IF NOT EXISTS idx_metrics_device_time ON metrics(device_id, observed_at);
CREATE INDEX IF NOT EXISTS idx_alerts_status ON alerts(status, created_at);
