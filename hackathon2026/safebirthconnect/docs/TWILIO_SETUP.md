# Twilio Setup Guide for SafeBirth Connect

This guide walks you through setting up Twilio for SMS integration with SafeBirth Connect.

## Prerequisites

1. A Twilio account (free trial available at https://www.twilio.com/try-twilio)
2. ngrok installed for local development (https://ngrok.com/download)
3. Java 21 and Maven installed
4. Backend running locally on port 8080

## Step 1: Create Twilio Account

1. Go to https://www.twilio.com/try-twilio
2. Sign up with email and verify your account
3. Note your **Account SID** and **Auth Token** from the dashboard

## Step 2: Get a Twilio Phone Number

### For Trial Account:
1. Go to Console → Phone Numbers → Buy a Number
2. Select a number with SMS capability
3. For testing, use the provided trial number

### Verify Test Phone Numbers (Trial Only):
1. Go to Console → Phone Numbers → Verified Caller IDs
2. Add phone numbers you'll use for testing
3. Verify each number via SMS or voice call

> **Note:** Trial accounts can only send SMS to verified numbers.

## Step 3: Install and Configure ngrok

### Windows (PowerShell):
```powershell
# Download ngrok from https://ngrok.com/download
# Or install via Chocolatey:
choco install ngrok

# Authenticate (get token from ngrok dashboard)
ngrok config add-authtoken YOUR_NGROK_TOKEN
```

### macOS/Linux:
```bash
# macOS via Homebrew
brew install ngrok

# Linux - download from website and add to PATH
# Then authenticate
ngrok config add-authtoken YOUR_NGROK_TOKEN
```

## Step 4: Configure Backend Environment

### Option A: Environment Variables (Recommended for Production)

```powershell
# Windows PowerShell
$env:TWILIO_ACCOUNT_SID = "ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$env:TWILIO_AUTH_TOKEN = "your_auth_token_here"
$env:TWILIO_PHONE_NUMBER = "+1234567890"
```

```bash
# macOS/Linux
export TWILIO_ACCOUNT_SID="ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export TWILIO_AUTH_TOKEN="your_auth_token_here"
export TWILIO_PHONE_NUMBER="+1234567890"
```

### Option B: application-prod.properties (Development Only)

Create `backend/src/main/resources/application-prod.properties`:
```properties
# Twilio Configuration
twilio.account-sid=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
twilio.auth-token=your_auth_token_here
twilio.phone-number=+1234567890

# Use real Twilio gateway
sms.gateway=twilio
```

> ⚠️ **Never commit credentials to version control!**

## Step 5: Start the Services

### 1. Start Backend:
```powershell
cd backend
mvn spring-boot:run -Dspring-boot.run.profiles=prod
```

The backend will start on http://localhost:8080

### 2. Start ngrok Tunnel:
```powershell
ngrok http 8080
```

Note the HTTPS URL (e.g., `https://abc123.ngrok-free.app`)

## Step 6: Configure Twilio Webhook

1. Go to Twilio Console → Phone Numbers → Manage → Active Numbers
2. Click on your phone number
3. Scroll to **Messaging Configuration**
4. Under "A MESSAGE COMES IN", set:
   - **Webhook URL:** `https://YOUR_NGROK_URL/api/sms/incoming`
   - **HTTP Method:** `POST`
5. Click **Save Configuration**

Example webhook URL:
```
https://abc123.ngrok-free.app/api/sms/incoming
```

## Step 7: Verify Setup

### Test the Webhook Endpoint:

Using curl:
```bash
curl -X POST https://YOUR_NGROK_URL/api/sms/incoming \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "From=+1234567890&To=+1555000000&Body=HELP"
```

Expected response (TwiML XML):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Message>📱 SafeBirth Commands:
  
  REGISTRATION:
  • REG MOTHER CAMP [name] ZONE [number]
  ...</Message>
</Response>
```

### Test with Real SMS:

1. Send an SMS to your Twilio number:
   ```
   HELP
   ```

2. You should receive a response with the list of available commands.

## Troubleshooting

### ngrok Issues

**Connection refused:**
- Ensure backend is running on port 8080
- Check firewall settings

**URL expired:**
- Free ngrok URLs change on restart
- Update Twilio webhook URL each time

### Twilio Issues

**Authentication failed:**
- Verify Account SID and Auth Token
- Check for typos in environment variables

**SMS not delivered:**
- Trial accounts can only send to verified numbers
- Check Twilio error logs in Console → Monitor → Logs

**Webhook not receiving:**
- Verify ngrok is running and URL is correct
- Check Twilio webhook configuration
- Look at ngrok web interface (http://127.0.0.1:4040) for requests

### Backend Issues

**Profile not loading:**
- Ensure `-Dspring-boot.run.profiles=prod` flag is used
- Check application-prod.properties exists

**Gateway not initialized:**
- Verify all Twilio credentials are set
- Check application logs for Twilio errors

## Production Deployment Notes

For production deployment:

1. **Never expose ngrok in production** - use proper HTTPS domain
2. **Secure credentials** - use environment variables or secret management
3. **Enable rate limiting** - protect against SMS spam
4. **Monitor costs** - Twilio charges per SMS
5. **Geographic compliance** - ensure SMS regulations are followed

## SMS Gateway Modes

SafeBirth Connect supports two SMS gateway modes:

### Mock Gateway (Development)
- Used when Twilio credentials are not configured
- SMS messages are logged to console and stored in memory
- Access via `/api/sms/simulate` endpoint

### Twilio Gateway (Production)
- Used when valid Twilio credentials are configured
- Real SMS messages are sent via Twilio
- Webhook receives incoming SMS at `/api/sms/incoming`

## Quick Reference

| Item | Value |
|------|-------|
| Twilio Console | https://console.twilio.com |
| ngrok Dashboard | https://dashboard.ngrok.com |
| Backend URL | http://localhost:8080 |
| ngrok Web UI | http://127.0.0.1:4040 |
| Webhook Endpoint | `/api/sms/incoming` |
| Simulate Endpoint | `/api/sms/simulate` |
| Health Check | `/api/sms/health` |

## Support

For Twilio support: https://support.twilio.com
For ngrok support: https://ngrok.com/docs
