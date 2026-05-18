import sqlite3
from pathlib import Path

DB_PATH = Path("data.db")

def get_conn() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db() -> None:
    conn = get_conn()
    cur = conn.cursor()

    # Volunteers: midwives/volunteers who can accept cases
    cur.execute("""
    CREATE TABLE IF NOT EXISTS volunteers (
        phone TEXT PRIMARY KEY,
        location_code TEXT NOT NULL,
        is_available INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
    )
    """)

    # Pregnant women (registered)
    cur.execute("""
    CREATE TABLE IF NOT EXISTS pregnancies (
        phone TEXT PRIMARY KEY,
        location_code TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
    )
    """)

    # Cases: HELP requests that move through states
    cur.execute("""
    CREATE TABLE IF NOT EXISTS cases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        requester_phone TEXT NOT NULL,
        location_code TEXT NOT NULL,
        status TEXT NOT NULL,
        accepted_by TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
    )
    """)

    # Events: audit log of every incoming command/action
    cur.execute("""
    CREATE TABLE IF NOT EXISTS events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        from_phone TEXT NOT NULL,
        raw_text TEXT NOT NULL,
        event_type TEXT NOT NULL,
        case_id INTEGER,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
    )
    """)

    # Outbox: messages the system wants to send (later becomes SMS)
    cur.execute("""
    CREATE TABLE IF NOT EXISTS outbox (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        to_phone TEXT NOT NULL,
        message TEXT NOT NULL,
        case_id INTEGER,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        sent INTEGER NOT NULL DEFAULT 0
    )
    """)

    conn.commit()
    conn.close()
