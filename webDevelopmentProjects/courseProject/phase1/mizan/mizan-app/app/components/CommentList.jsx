"use client";
import React, { useState, useEffect } from "react";
import Course from "@/app/model/Course";
import Comment from "@/app/model/Comment";
import User from "@/app/model/User";
import CommentForm from "@/app/components/CommentForm";
import Loading from "./Loading";
import { useRouter } from "next/navigation";

export default function CommentList() {
  const [comments, setComments] = useState([]);
  const [comment, setComment] = useState({});
  const [submitting, setSubmitting] = useState(false);
  const [replyTo, setReplyTo] = useState(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    const fetchingComments = async (e) => {
      try {
        const course = JSON.parse(localStorage.getItem("currentCourse"));
        const courseId = course.id;
        const user = JSON.parse(localStorage.getItem("user"));
        const currentSem = JSON.parse(localStorage.getItem("currentSem"));
        const response = await fetch(
          `/api/semesters/${currentSem}/courses/${courseId}/comments`,
          {
            method: "GET",
            headers: {
              "Content-Type": "application/json",
            },
          }
        );

        const data = await response.json();

        if (!data.error) {
          const commentObjects = await Promise.all(
            data.map(async (commentData) => {
              const comment = new Comment(commentData);
              let commenter = null;
              try {
                const commtrRes = await fetch(
                  `/api/users/${comment.commenterId}`
                );
                const commtrData = await commtrRes.json();
                if (!commtrData.error) {
                  commenter = new User(commtrData);
                }
              } catch (err) {
                console.error(err);
              }
              return { comment: comment, commenter };
            })
          );
          const commentTree = buildCommentTree(commentObjects);
          setComments(commentTree);
        } else {
          console.error(data.error);
        }
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchingComments();
  }, []);

  async function handleSubmit(e, commentId, localComment) {
    e.preventDefault();
    setSubmitting(true);
    try {
      const course = JSON.parse(localStorage.getItem("currentCourse"));
      const currentSem = JSON.parse(localStorage.getItem("currentSem"));
      const courseId = course.id;
      const user = JSON.parse(localStorage.getItem("user"));
      const response = await fetch(
        `/api/semesters/${currentSem}/courses/${courseId}/comments`,
        {
          method: "POST",
          body: JSON.stringify({
            courseId: courseId,
            commenterId: user.id,
            title: localComment.title,
            body: localComment.body,
            parentCommentId: commentId,
          }),
        }
      );

      const data = await response.json();

      if (!data.error) {
        window.location.href = "/home/courses/course/comments";
        //router.push("/home/courses/course/comments");
      } else {
        console.error(data.error);
      }
    } catch (error) {
      console.log(error);
    } finally {
      setSubmitting(false);
    }
  }

  function toggleReplyForm(commentId) {
    setReplyTo((prev) => (prev === commentId ? null : commentId));
    setComment({ title: "", body: "" });
  }

  const buildCommentTree = (comments) => {
    const commentMap = {};
    const roots = [];

    comments.forEach(({ comment, commenter }) => {
      commentMap[comment.id] = { comment, commenter, replies: [] };
    });

    comments.forEach(({ comment }) => {
      if (comment.parentCommentId) {
        const parent = commentMap[comment.parentCommentId];
        if (parent) {
          parent.replies.push(commentMap[comment.id]);
        }
      } else {
        roots.push(commentMap[comment.id]);
      }
    });

    return roots;
  };

  const [showPopup, setShowPopup] = useState(false);

  const createComment = async (e, localComment) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      const course = JSON.parse(localStorage.getItem("currentCourse"));
      const currentSem = JSON.parse(localStorage.getItem("currentSem"));
      const courseId = course.id;
      const user = JSON.parse(localStorage.getItem("user"));
      const response = await fetch(
        `/api/semesters/${currentSem}/courses/${courseId}/comments`,
        {
          method: "POST",
          body: JSON.stringify({
            courseId: courseId,
            commenterId: user.id,
            title: localComment.title,
            body: localComment.body,
          }),
        }
      );

      const data = await response.json();

      if (!data.error) {
        window.location.href = "/home/courses/course/comments";
        //router.push("/home/courses/course/comments");
      } else {
        console.error(data.error);
      }
    } catch (error) {
      console.log(error);
    } finally {
      setSubmitting(false);
    }
  };

  const renderComments = (commentList) => {
    return commentList.length === 0 ? (
      <>
        <div className="no-comments">
          <h4>No comments yet.</h4>
          <h5>Be the first to comment!</h5>
        </div>
        <button className="floating-add-btn" onClick={() => setShowPopup(true)}>
          <i className="bi bi-plus"></i>
        </button>

        {showPopup && (
          <div className="popup-overlay">
            <div className="popup">
              <h4>Add a comment</h4>
              <div className="add-form-popup">
                <CommentForm
                  submitting={submitting}
                  handleSubmit={(e, localComment) =>
                    createComment(e, localComment)
                  }
                />
                <div className="close-popup">
                  <button
                    className="close-popup-btn"
                    onClick={() => setShowPopup(false)}
                  >
                    X
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </>
    ) : (
      commentList.map(({ comment, commenter, replies }) => (
        <>
          <div key={comment.id} className="comment">
            <div className="commenter-container">
              <div className="user-initials">
                {commenter?.name
                  .split(" ")
                  .map((namePart) => namePart[0].toUpperCase())
                  .join("")}
              </div>
              <h5 id="user-name">{commenter?.name}</h5>
            </div>
            <h4 id="comment-title">{comment.title}</h4>
            <p id="comment-body">{comment.body}</p>

            <div className="reply-container">
              <button
                className="reply-button"
                onClick={() => toggleReplyForm(comment.id)}
              >
                <i className="bi bi-reply"></i>
              </button>
            </div>
            <p id="comment-date">
              {
                new Date(
                  comment.date
                ).toLocaleString() /*.toISOString().split('T')[0]*/
              }
            </p>
            <button
              className="floating-add-btn"
              onClick={() => setShowPopup(true)}
            >
              <i className="bi bi-plus"></i>
            </button>

            {showPopup && (
              <div className="popup-overlay">
                <div className="popup">
                  <div className="close-popup">
                    <button
                      className="close-popup-btn"
                      onClick={() => setShowPopup(false)}
                    >
                      X
                    </button>
                  </div>
                  <h4>Add a comment</h4>
                  <div className="add-form-popup">
                    <CommentForm
                      submitting={submitting}
                      handleSubmit={(e, localComment) =>
                        createComment(e, localComment)
                      }
                    />
                  </div>
                </div>
              </div>
            )}
            <div className="arrowhead"></div>
          </div>
          {replyTo === comment.id && (
            <div className="reply-form">
              <CommentForm
                submitting={submitting}
                handleSubmit={(e, localComment) =>
                  handleSubmit(e, comment.id, localComment)
                }
              />
            </div>
          )}
          {replies && replies.length > 0 && (
            <div className="nested-replies">{renderComments(replies)}</div>
          )}
        </>
      ))
    );
  };

  useEffect(() => {
    document.querySelectorAll(".nested-replies").forEach((el) => {
      el.style.setProperty("--line-height", `${el.scrollHeight}px`);
    });
  }, []);

  return loading ? <Loading></Loading> : renderComments(comments);
}
