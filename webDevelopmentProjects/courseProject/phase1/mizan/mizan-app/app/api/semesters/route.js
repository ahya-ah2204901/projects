import semesterRepo from "@/app/repo/SemesterRepo";

// returns all semesters
export async function GET(request) {
  try {
    const semesters = await semesterRepo.getAllSemesters();
    return Response.json(semesters, { status: 200 });
  } catch (e) {
    console.log("Error" + e);
  }
}
