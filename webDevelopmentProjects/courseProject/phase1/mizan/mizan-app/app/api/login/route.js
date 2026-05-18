import userRepo from "@/app/repo/UserRepo";

// authenticates (and returns) a user by email and password
export async function POST(request) {
  try {
    const { email, password } = await request.json();
    const result = await userRepo.login(email, password);

    // login failure
    if (result.error) {
      return Response.json({ error: result.error }, { status: 401 });
    }

    // login success
    const { password: _, ...safeUser } = result;
    return Response.json({ user: safeUser }, { status: 200 });

    // error
  } catch (err) {
    return Response.json({ error: "Invalid request." }, { status: 400 });
  }
}
