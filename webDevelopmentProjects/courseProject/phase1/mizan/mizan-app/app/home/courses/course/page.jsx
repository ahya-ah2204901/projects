"use client";
import React from "react";
import Toggle from "../../../components/Toggle";

export default function CoursePage() {
  const course = JSON.parse(localStorage.getItem("currentCourse"));
  return (
    <div className="course-deets">
      <p>
        <b>Course Description:</b> {course.description}
        <br />
        <b>Course Credits:</b> {course.creditHours}
        <br />
        <b>Course Program:</b> {course.program}
        <br />
        <b>Semester:</b> {course.sem}
      </p>
    </div>
  );
}
