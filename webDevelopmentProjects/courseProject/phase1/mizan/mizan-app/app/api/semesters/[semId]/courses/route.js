import courseRepo from "@/app/repo/CourseRepo";

// returns all courses of a semester (for a user)
export async function GET(request, { params }) {
  try {
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get("userId");

    if (!userId) {
      return Response.json({ error: "Missing userId" }, { status: 400 });
    }

    const semId = (await params).semId;
    const courses = await courseRepo.getCoursesByUserBySem(userId, semId);
    return Response.json(courses, { status: 200 });
  } catch (e) {
    console.log("Error" + e);
  }
}
