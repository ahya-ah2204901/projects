import courseRepo from "@/app/repo/CourseRepo";

// returns a sigle course by id
export async function GET(request, { params }) {
  try {
    const courseId = (await params).courseId;
    const course = await courseRepo.getCourseById(courseId);
    return Response.json(course, { status: 200 });
  } catch (e) {
    console.log("Error" + e);
  }
}
