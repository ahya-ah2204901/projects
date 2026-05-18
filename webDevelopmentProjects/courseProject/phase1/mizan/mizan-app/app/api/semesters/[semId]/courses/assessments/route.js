import assessmentRepo from "@/app/repo/AssessmentRepo";

// returns all assessments from all courses of a semester (for a user)
export async function GET(request, { params }) {
  try {
    const semId = (await params).semId;
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get("userId");
    const topDue = searchParams.get("topDue");

    if (!userId) {
      return Response.json({ error: "Missing userId" }, { status: 400 });
    }

    const assessments = await assessmentRepo.getAssessmentsByUserBySem(
      userId,
      semId,
      topDue
    );
    return Response.json(assessments, { status: 200 });
  } catch (e) {
    console.log("Error" + e);
  }
}
