import userRepo from "@/app/repo/UserRepo";

// returns all users
export async function GET(request) {
  try {
    const users = await userRepo.getAllUsers();
    return Response.json(users, { status: 200 });
  } catch (e) {
    console.log("Error" + e);
  }
}
