"use client";
import React, { useState, useEffect } from "react";
import Course from "@/app/model/Course";
import User from "@/app/model/User";
import Loading from "./Loading";
import { useRouter } from "next/navigation";

export default function CoursesList() {
  const [courses, setCourses] = useState([]);
  const router = useRouter();

  useEffect(() => {
    const fetchingCourses = async (e) => {
      try {
        const user = JSON.parse(localStorage.getItem("user"));
        const currentSem = JSON.parse(localStorage.getItem("currentSem"));
        const response = await fetch(
          `/api/semesters/${currentSem}/courses?userId=${user.id}`,
          {
            method: "GET",
            headers: {
              "Content-Type": "application/json",
            },
          }
        );

        const data = await response.json();

        if (!data.error) {
          const courseObjects = await Promise.all(
            data.map(async (courseData) => {
              const course = new Course(courseData);
              let instructor = null;
              try {
                const instrRes = await fetch(
                  `/api/users/${course.instructorId}`
                );
                const instrData = await instrRes.json();
                if (!instrData.error) {
                  instructor = new User(instrData);
                }
              } catch (err) {
                console.error(err);
              }
              return { course: course, instructor };
            })
          );
          setCourses(courseObjects);
        } else {
          console.error(data.error);
        }
      } catch (err) {
        console.error(err);
      }
    };
    fetchingCourses();
  }, []);

  async function handleClick(course) {
    try {
      const currentSem = JSON.parse(localStorage.getItem("currentSem"));
      const response = await fetch(
        `/api/semesters/${currentSem}/courses/${course.id}`,
        {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
          },
        }
      );

      const data = await response.json();

      if (!data.error) {
        localStorage.currentCourse = JSON.stringify(data);
        console.log(localStorage.currentCourse);
        router.push("/home/courses/course");
      } else {
        console.error(data.error);
      }
    } catch (err) {
      console.log(err);
    }
  }

  return courses.length === 0 ? (
    <Loading></Loading>
  ) : (
    courses.map((obj, index) => {
      return (
        <div
          className="list-card"
          onClick={() => handleClick(obj.course)}
          key={index}
        >
          <div id="course-code">
            <div id="tags">{obj.course.code.toUpperCase()}</div>
            <div id="tags">{obj.course.sem.toUpperCase()}</div>
            <div id="tags">{obj.course.creditHours}HRS</div>
            {/* {obj.course.code.toUpperCase()} | {obj.course.sem.toUpperCase()} |{" "}
            {obj.course.creditHours}HRS */}
          </div>
          <h4 id="course-title">{obj.course.title}</h4>
          <p id="instructor-details" className="subhead">
            Instructor | {obj.instructor?.name}
          </p>
        </div>
      );
    })
  );
}
