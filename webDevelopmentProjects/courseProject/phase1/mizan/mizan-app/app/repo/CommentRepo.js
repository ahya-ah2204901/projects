import fs from "fs-extra";
import path from "path";
import Course from "@/app/model/Course";
import Comment from "@/app/model/Comment";
import User from "@/app/model/User";

class CommentRepo {
  constructor() {
    this.courseFilePath = path.join(process.cwd(), "app/data/courses.json");
    this.userFilePath = path.join(process.cwd(), "app/data/users.json");
    this.commentsFilePath = path.join(process.cwd(), "app/data/comments.json");
  }

  async addComment(comment) {
    const newComment = Comment.fromJSON(comment);
    const comments = await this.getAllComments();
    comments.push(newComment);
    await fs.writeJson(this.commentsFilePath, comments, { spaces: 2 });
    return newComment;
  }

  async saveComments(comments) {
    await fs.writeJson(this.commentsFilePath, comments);
  }

  async getAllComments() {
    const comments = await fs.readJson(this.commentsFilePath);
    const commentsList = comments.map((c) => new Comment(c));
    commentsList.sort((a, b) => new Date(a.date) - new Date(b.date));
    return commentsList;
  }

  async getCommentsByCourse(courseId) {
    const allComments = await this.getAllComments();

    const courseComments = allComments.filter((c) => c.courseId === courseId);

    return courseComments;
  }
}

export default new CommentRepo();
