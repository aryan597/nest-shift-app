#!/bin/bash
# NestShift Brain - Database Setup Script
# Run this on the Raspberry Pi in the nestshift_brain container

echo "Setting up brain database..."

# Connect to the SQLite database and create the required table
sqlite3 /app/nestshift_brain.db << 'EOF'
-- Create paired_tokens table for authentication
CREATE TABLE IF NOT EXISTS paired_tokens (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    token TEXT UNIQUE NOT NULL,
    device_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_used TIMESTAMP,
    revoked INTEGER DEFAULT 0
);

-- Create initial demo token (for testing)
INSERT OR IGNORE INTO paired_tokens (token, device_id) 
VALUES ('demo_token_123456789', 'flutter_app_demo');

-- Create devices table (if not exists)
CREATE TABLE IF NOT EXISTS devices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT,
    pin_number INTEGER,
    state INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create commands history table
CREATE TABLE IF NOT EXISTS commands (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    command_text TEXT NOT NULL,
    devices_affected TEXT,
    success INTEGER DEFAULT 1,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOF

echo "Database setup complete!"
echo "Demo token created: demo_token_123456789"
echo ""
echo "Restart the brain service with:"
echo "  docker-compose restart nestshift_brain"