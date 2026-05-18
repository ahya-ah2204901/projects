# from fastapi import FastAPI
# from pydantic import BaseModel
# # from db import get_conn
# from db import init_db
# from engine import handle_incoming_sms

# app = FastAPI(title="Ghost Clinic Offline Engine")

# @app.on_event("startup")
# def startup():
#     init_db()

# class SMSIn(BaseModel):
#     from_phone: str
#     text: str

# @app.post("/sms/incoming")
# def sms_incoming(payload: SMSIn):
#     reply, outgoing = handle_incoming_sms(payload.from_phone, payload.text)
#     return {
#         "reply_to_sender": reply,
#         "outgoing_messages": [{"to": to, "message": msg} for to, msg in outgoing]
#     }

# @app.get("/health")
# def health():
#     return {"ok": True}


# # @app.get("/outbox")
# # def get_outbox():
# #     conn = get_conn()
# #     cur = conn.execute(
# #         "SELECT id, to_phone, message, case_id, created_at FROM outbox ORDER BY created_at DESC"
# #     )
# #     rows = [dict(r) for r in cur.fetchall()]
# #     conn.close()
# #     return rows

from fastapi import FastAPI, Form, Response
from pydantic import BaseModel
from db import init_db
from engine import handle_incoming_sms

# Twilio TwiML response builder
from twilio.twiml.messaging_response import MessagingResponse

app = FastAPI(title="Ghost Clinic Offline Engine")

@app.on_event("startup")
def startup():
    init_db()

# --------- Simulator endpoint (JSON) ---------
class SMSIn(BaseModel):
    from_phone: str
    text: str

@app.post("/sms/incoming")
def sms_incoming(payload: SMSIn):
    reply, outgoing = handle_incoming_sms(payload.from_phone, payload.text)
    return {
        "reply_to_sender": reply,
        "outgoing_messages": [{"to": to, "message": msg} for to, msg in outgoing]
    }

# --------- Twilio endpoint (real SMS webhook) ---------
@app.post("/twilio/sms/incoming")
def twilio_sms_incoming(
    From: str = Form(...),
    Body: str = Form(...)
):
    reply, _outgoing = handle_incoming_sms(From, Body)

    # Twilio requires TwiML XML in the response to send an SMS back to the sender
    twiml = MessagingResponse()
    twiml.message(reply)
    return Response(content=str(twiml), media_type="application/xml")

@app.get("/health")
def health():
    return {"ok": True}

