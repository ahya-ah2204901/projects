import { getToken } from "next-auth/jwt";

export async function POST(req) {
  const token = await getToken({ req });
  if (!token?.accessToken) {
    return Response.json({ error: "No access token" }, { status: 401 });
  }

  const body = await req.json();

  const googleResponse = await fetch(
    'https://www.googleapis.com/calendar/v3/calendars/primary/events',
    {
      method: 'POST',
      headers: {
        "Authorization": `Bearer ${token.accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    }
  );

  const result = await googleResponse.json();

  return new Response(JSON.stringify(result), {
    status: googleResponse.status,
    headers: { "Content-Type": "application/json" }
  });
}