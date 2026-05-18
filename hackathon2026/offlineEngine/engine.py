from dataclasses import dataclass
from typing import Optional, List, Tuple
from db import get_conn

# ---- The "model": states + rules ----
CASE_NEW = "DISPATCHED"
CASE_ACCEPTED = "ACCEPTED"
CASE_ARRIVED = "ARRIVED"
CASE_RESOLVED = "RESOLVED"
CASE_ESCALATED = "ESCALATED"

@dataclass
class ParsedCommand:
    cmd: str
    arg1: Optional[str] = None
    arg2: Optional[str] = None

def parse_sms(text: str) -> ParsedCommand:
    """
    Supported commands:
      REGV <LOC>
      REGP <LOC>
      ON / OFF
      HELP <LOC>
      ACCEPT <CASE_ID>
      ARRIVE <CASE_ID>
      DONE <CASE_ID>
    """
    parts = text.strip().upper().split()
    if not parts:
        return ParsedCommand(cmd="INVALID")

    cmd = parts[0]
    arg1 = parts[1] if len(parts) > 1 else None
    return ParsedCommand(cmd=cmd, arg1=arg1)

def log_event(from_phone: str, raw_text: str, event_type: str, case_id: Optional[int] = None) -> None:
    conn = get_conn()
    conn.execute(
        "INSERT INTO events (from_phone, raw_text, event_type, case_id) VALUES (?, ?, ?, ?)",
        (from_phone, raw_text, event_type, case_id),
    )
    conn.commit()
    conn.close()

def queue_message(to_phone: str, message: str, case_id: Optional[int] = None) -> None:
    conn = get_conn()
    conn.execute(
        "INSERT INTO outbox (to_phone, message, case_id) VALUES (?, ?, ?)",
        (to_phone, message, case_id),
    )
    conn.commit()
    conn.close()

def register_volunteer(phone: str, loc: str) -> str:
    conn = get_conn()
    conn.execute(
        "INSERT OR REPLACE INTO volunteers (phone, location_code, is_available) VALUES (?, ?, 1)",
        (phone, loc),
    )
    conn.commit()
    conn.close()
    return f"Registered volunteer at {loc}. Reply OFF when unavailable."

def register_pregnancy(phone: str, loc: str) -> str:
    conn = get_conn()
    conn.execute(
        "INSERT OR REPLACE INTO pregnancies (phone, location_code) VALUES (?, ?)",
        (phone, loc),
    )
    conn.commit()
    conn.close()
    return f"Registered pregnancy at {loc}. When labor starts, text: HELP {loc}"

def set_availability(phone: str, available: bool) -> str:
    conn = get_conn()
    cur = conn.execute("SELECT phone FROM volunteers WHERE phone = ?", (phone,))
    row = cur.fetchone()
    if not row:
        conn.close()
        return "You are not registered. Text: REGV <LOC>"
    conn.execute("UPDATE volunteers SET is_available = ? WHERE phone = ?", (1 if available else 0, phone))
    conn.commit()
    conn.close()
    return "Status set to ON (available)." if available else "Status set to OFF (unavailable)."

def create_case(requester_phone: str, loc: str) -> int:
    conn = get_conn()
    cur = conn.execute(
        "INSERT INTO cases (requester_phone, location_code, status) VALUES (?, ?, ?)",
        (requester_phone, loc, CASE_NEW),
    )
    case_id = cur.lastrowid
    conn.commit()
    conn.close()
    return int(case_id)

def pick_volunteers(loc: str, limit: int = 3) -> List[str]:
    conn = get_conn()
    cur = conn.execute(
        """
        SELECT phone FROM volunteers
        WHERE location_code = ? AND is_available = 1
        ORDER BY created_at ASC
        LIMIT ?
        """,
        (loc, limit),
    )
    phones = [r["phone"] for r in cur.fetchall()]
    conn.close()
    return phones

def accept_case(vol_phone: str, case_id: int) -> str:
    conn = get_conn()
    cur = conn.execute("SELECT status, accepted_by, location_code FROM cases WHERE id = ?", (case_id,))
    row = cur.fetchone()
    if not row:
        conn.close()
        return f"Case {case_id} not found."

    if row["accepted_by"]:
        conn.close()
        return f"Case {case_id} already accepted by {row['accepted_by']}."

    conn.execute(
        "UPDATE cases SET status = ?, accepted_by = ?, updated_at = datetime('now') WHERE id = ?",
        (CASE_ACCEPTED, vol_phone, case_id),
    )
    conn.commit()
    conn.close()
    return f"You accepted case {case_id}. Reply ARRIVE {case_id} when you arrive."

def update_case_status(case_id: int, new_status: str) -> str:
    conn = get_conn()
    cur = conn.execute("SELECT id FROM cases WHERE id = ?", (case_id,))
    row = cur.fetchone()
    if not row:
        conn.close()
        return f"Case {case_id} not found."
    conn.execute(
        "UPDATE cases SET status = ?, updated_at = datetime('now') WHERE id = ?",
        (new_status, case_id),
    )
    conn.commit()
    conn.close()
    return f"Case {case_id} updated to {new_status}."

def handle_incoming_sms(from_phone: str, text: str) -> Tuple[str, List[Tuple[str, str]]]:
    """
    Returns: (reply_to_sender, outgoing_messages_to_others)
    outgoing_messages_to_others: list of (to_phone, message)
    """
    cmd = parse_sms(text)
    outgoing: List[Tuple[str, str]] = []

    if cmd.cmd == "REGV" and cmd.arg1:
        log_event(from_phone, text, "REGV")
        reply = register_volunteer(from_phone, cmd.arg1)
        return reply, outgoing

    if cmd.cmd == "REGP" and cmd.arg1:
        log_event(from_phone, text, "REGP")
        reply = register_pregnancy(from_phone, cmd.arg1)
        return reply, outgoing

    if cmd.cmd == "ON":
        log_event(from_phone, text, "ON")
        reply = set_availability(from_phone, True)
        return reply, outgoing

    if cmd.cmd == "OFF":
        log_event(from_phone, text, "OFF")
        reply = set_availability(from_phone, False)
        return reply, outgoing

    if cmd.cmd == "HELP" and cmd.arg1:
        loc = cmd.arg1
        case_id = create_case(from_phone, loc)
        log_event(from_phone, text, "HELP", case_id)

        # Dispatch rule: alert up to 3 available volunteers in same location
        vols = pick_volunteers(loc, limit=3)
        if not vols:
            reply = f"Received HELP {loc}. Case #{case_id}. No volunteers available right now. Try again soon."
            return reply, outgoing

        for v in vols:
            msg = f"NEW CASE #{case_id} at {loc}. Reply: ACCEPT {case_id}"
            outgoing.append((v, msg))
            queue_message(v, msg, case_id)

        reply = f"Received HELP {loc}. Case #{case_id}. Notifying nearby midwives."
        return reply, outgoing

    if cmd.cmd == "ACCEPT" and cmd.arg1 and cmd.arg1.isdigit():
        case_id = int(cmd.arg1)
        log_event(from_phone, text, "ACCEPT", case_id)
        reply = accept_case(from_phone, case_id)
        return reply, outgoing

    if cmd.cmd == "ARRIVE" and cmd.arg1 and cmd.arg1.isdigit():
        case_id = int(cmd.arg1)
        log_event(from_phone, text, "ARRIVE", case_id)
        reply = update_case_status(case_id, CASE_ARRIVED)
        return reply, outgoing

    if cmd.cmd == "DONE" and cmd.arg1 and cmd.arg1.isdigit():
        case_id = int(cmd.arg1)
        log_event(from_phone, text, "DONE", case_id)
        reply = update_case_status(case_id, CASE_RESOLVED)
        return reply, outgoing

    log_event(from_phone, text, "INVALID")
    return "Invalid command. Use: REGV <LOC>, REGP <LOC>, HELP <LOC>, ACCEPT <ID>, ARRIVE <ID>, DONE <ID>", outgoing
