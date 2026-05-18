"use client";
import React, { useState, useEffect } from "react";
import Select from "react-select";
import Assessment from "@/app/model/Assessment";
import User from "@/app/model/User";
import Loading from "./Loading";
import { usePathname } from "next/navigation";

export default function AssessmentsWidget() {
  const [assessments, setAssessments] = useState([]);
  const [user, setUser] = useState(null);
  const [selectedCourses] = useState([]);

  useEffect(() => {
    const userData = JSON.parse(localStorage.getItem("user"));
    const currentUser = new User(userData);
    setUser(currentUser);
  }, []);

  useEffect(() => {
    fetchingDueAssessments();
    fetchingCourseIds();
  }, [user]);

  const getDaysLeft = (due) => {
    const days = Math.ceil((new Date(due) - new Date()) / (1000 * 3600 * 24));
    if (days == 0) {
      return "Today";
    } else if (days == 1) {
      return "Tomorrow";
    } else {
      return `${days} days left`;
    }
  };

  const fetchingDueAssessments = async (e) => {
    try {
      const currentSem = JSON.parse(localStorage.getItem("currentSem"));
      const fetchingURL = `/api/semesters/${currentSem}/courses/assessments?userId=${user.id}&topDue=5`;
      const response = await fetch(fetchingURL, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
      });

      const data = await response.json();

      if (!data.error) {
        const assessmentObjects = data.map(
          (assessment) => new Assessment(assessment)
        );
        setAssessments(assessmentObjects);
      } else {
        console.error(data.error);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const fetchingCourseIds = async (e) => {
    const currentSem = JSON.parse(localStorage.getItem("currentSem"));
    try {
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
        const mappedCourseIds = data.map((c) => ({
          value: c.id,
          label: c.id.slice(0, 7).toUpperCase(),
        }));
        setCourseOptions(mappedCourseIds);
      } else {
        console.error(data.error);
      }
    } catch (err) {
      console.error(err);
    }
  };

  return assessments.length === 0 ? (
    <Loading></Loading>
  ) : (
    <>
      {assessments
        .filter((a) => {
          return selectedCourses.length === 0
            ? true
            : selectedCourses.some((selected) => selected.value === a.courseId);
        })
        .map((a, index) => {
          return (
            <div className="widget-card" key={index}>
              <div className="widget-card-details">
                <div className="div-title">
                  {" "}
                  <i className="bi bi-check-circle"></i>
                  <p id="assessment-title">{a.title}</p>
                </div>
                <div id="assessment-details">
                  <div id="tags">{getDaysLeft(a.dueDate)}</div>
                  <div id="tags">
                    {new Date(a.dueDate).toLocaleDateString()}
                  </div>{" "}
                  <div id="tags">{a.courseId.slice(0, 7).toUpperCase()}</div>
                </div>
              </div>
            </div>
          );
        })}
    </>
  );
}
