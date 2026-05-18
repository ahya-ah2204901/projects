import commentRepo from "@/app/repo/CommentRepo";

// returns all comments fopr a course
export async function GET(request, { params }) {
  try {
    const courseId = (await params).courseId;
    const comments = await commentRepo.getCommentsByCourse(courseId);
    return Response.json(comments, { status: 200 });
  } catch (e) {
    console.log("Error" + e);
  }
}

// adding a new comment
export async function POST(req) {
  try {
    const comment = await req.json();
    const newComment = await commentRepo.addComment(comment);
    return Response.json(newComment, { status: 201 });
  } catch (e) {
    return Response.json({ error: e.message }, { status: 400 });
  }
}
