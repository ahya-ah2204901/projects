import userRepo from "@/app/repo/UserRepo";

// returns a sigle user by email
export async function GET(request, { params }) {
  try {
    const userId = (await params).userId;
    const user = await userRepo.getUserById(userId);
    return Response.json(user, { status: 200 });
  } catch (e) {
    console.log("Error" + e);
  }
}
