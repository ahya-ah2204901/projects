import assessmentRepo from "@/app/repo/AssessmentRepo";

// returns all assessments of a course of a semester
export async function GET(request, { params }) {
  try {
    const courseId = (await params).courseId;
    const assessments = await assessmentRepo.getAssessmentsByCourse(courseId);
    return Response.json(assessments, { status: 200 });
  } catch (e) {
    console.log("Error" + e);
  }
}

// adds a new assessment to a course of a semester
export async function POST(req) {
  try {
    const assessment = await req.json();
    const newAssessment = await assessmentRepo.addAssessment(assessment);
    return Response.json(newAssessment, { status: 201 });
  } catch (e) {
    return Response.json({ error: e.message }, { status: 400 });
  }
}
