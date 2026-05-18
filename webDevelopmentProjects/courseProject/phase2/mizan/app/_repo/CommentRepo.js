import userRepo from "./UserRepo";
import prisma from "@/lib/prisma";

class CommentRepo {
  async getComments(sectionCRN) {
    const comments = await prisma.comment.findMany({
      where: { sectionCRN: sectionCRN },
      include: { author: true },
    });
    const commentsWithAuthorNames = comments.map((c) => {
      return { ...c, authorName: `${c.author.firstName} ${c.author.lastName}` };
    });
    return commentsWithAuthorNames;
  }

  async getCommentReplies(commentId) {
    const replies = await prisma.comment.findMany({
      where: { replyToCommentId: parseInt(commentId) },
      include: { author: true },
    });
    const repliesWithAuthorNames = replies.map((r) => {
      return { ...r, authorName: `${r.author.firstName} ${r.author.lastName}` };
    });
    return repliesWithAuthorNames;
  }

  async addComment(comment) {
    return await prisma.comment.create({
      data: comment,
    });
  }

  async deleteComment(commentId) {
    // delete replies
    await prisma.comment.deleteMany({
      where: { replyToCommentId: parseInt(commentId) },
    });
  
    // delete the main comment
    return await prisma.comment.delete({
      where: { id: parseInt(commentId) },
    });
  }
}

export default new CommentRepo();
