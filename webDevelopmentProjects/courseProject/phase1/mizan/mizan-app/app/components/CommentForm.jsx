"use client";
import React, { useState, useEffect } from "react";

export default function CommentForm({
  initialComment = { title: "", body: "" },
  submitting,
  handleSubmit,
}) {
  const [localComment, setLocalComment] = useState(initialComment);

  useEffect(() => {
    if (!submitting) {
      setLocalComment({ title: "", body: "" });
    }
  }, [submitting]);

  const onSubmit = (e) => {
    e.preventDefault();
    handleSubmit(e, localComment);
  };

  return (
    <form onSubmit={onSubmit}>
      <div className="commenter-box">
        <input
          type="text"
          onChange={(e) =>
            setLocalComment({ ...localComment, title: e.target.value })
          }
          placeholder="Title"
          required
          className="comment-title-box"
        />
        <textarea
          value={localComment.body}
          onChange={(e) =>
            setLocalComment({ ...localComment, body: e.target.value })
          }
          placeholder="Write your comment here..."
          required
          className="comment-body-box no-resize"
        />
      </div>
      <div className="form-btns">
        <div className="submit-btn-container">
          <button type="submit" className="submit-btn" disabled={submitting}>
            {submitting ? "Adding..." : "Add"}
          </button>
        </div>
      </div>
    </form>
  );
}
