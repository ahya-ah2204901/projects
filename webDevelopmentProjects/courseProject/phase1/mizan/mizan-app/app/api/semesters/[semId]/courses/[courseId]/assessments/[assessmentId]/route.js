import assessmentRepo from "@/app/repo/AssessmentRepo";

// returns a assessment by id
export async function GET(request, { params }) {
  try {
    const assessmentId = (await params).assessmentId;
    const assessment = await assessmentRepo.getAssessmentById(assessmentId);
    return Response.json(assessment, { status: 200 });
  } catch (e) {
    console.log("Error" + e);
  }
}

// updates an existing assessment
export async function PUT(req, { params }) {
  try {
    const assessmentId = (await params).assessmentId;
    const assessment = await req.json();
    const updatedAssessment = await assessmentRepo.updateAssessment(
      assessmentId,
      assessment
    );
    return Response.json(updatedAssessment, { status: 200 });
  } catch (e) {
    return Response.json({ error: e.message }, { status: 400 });
  }
}

// deletes an existing assessment
export async function DELETE(req, { params }) {
  const assessmentId = (await params).assessmentId;
  const deletedassessment = await assessmentRepo.deleteAssessment(assessmentId);
  return Response.json(deletedassessment, { status: 200 });
}
