import semesterRepo from "@/app/repo/SemesterRepo";

// returns a sigle semester by id
export async function GET(request, { params }) {
  try {
    const semId = (await params).semId;
    const semester = await semesterRepo.getSemesterById(semId);
    return Response.json(semester, { status: 200 });
  } catch (e) {
    console.log("Error" + e);
  }
}
