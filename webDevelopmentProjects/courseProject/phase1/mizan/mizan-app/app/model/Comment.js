import { nanoid } from "nanoid";

export default class Comment {
  constructor({
    id,
    courseId,
    commenterId,
    title,
    body,
    date,
    parentCommentId = null,
  }) {
    const randId = nanoid(12);
    this.id = id || `${courseId}-${randId}`; // courseId-[random] if not passed
    this.courseId = courseId;
    this.commenterId = commenterId;
    this.title = title;
    this.body = body;
    this.date = date || new Date(Date.now()); // should not be passed, just set as curreent time
    this.parentCommentId = parentCommentId; // only applicable to replies, otherwise null
  }

  isReply() {
    return this.parentCommentId !== null;
  }

  static fromJSON(json) {
    const randId = nanoid(12);
    return new Comment({
      id: json.id ?? `${json.courseId}-${randId}`,
      courseId: json.courseId,
      commenterId: json.commenterId,
      title: json.title,
      body: json.body,
      date: json.date ?? new Date(Date.now()),
      parentCommentId: json.parentCommentId ?? null,
    });
  }

  static toJSON(comment) {
    return {
      id: comment.id,
      courseId: comment.courseId,
      commenterId: comment.commenterId,
      title: comment.title,
      body: comment.body,
      date: comment.date,
      parentCommentId: comment.parentCommentId,
    };
  }
}
