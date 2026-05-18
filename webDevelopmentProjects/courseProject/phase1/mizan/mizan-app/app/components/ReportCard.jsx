"use client";
import React, { useState, useEffect, useRef } from "react";
import Course from "@/app/model/Course";
import Chart from "chart.js/auto";
import Assessment from "../model/Assessment";
import Loading from "./Loading";

export default function ReportCard() {
  const [loading, setLoading] = useState(true);
  const chartRef = useRef(null);
  const [courses, setCourses] = useState([]);

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
              let assessments = [];
              try {
                const assessRes = await fetch(
                  `/api/semesters/${currentSem}/courses/${course.id}/assessments`
                );
                const assessData = await assessRes.json();
                if (!assessData.error) {
                  assessments = assessData.map((a) => new Assessment(a));
                }
              } catch (err) {
                console.error(err);
              }
              return { course: course, assessments };
            })
          );
          setCourses(courseObjects);
        } else {
          console.error(data.error);
        }
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchingCourses();
  }, []);

  useEffect(() => {
    if (!chartRef.current || courses.length === 0) return;
    const ctx = chartRef.current.getContext("2d");
    const labels = courses.map(({ course }) => course.code.toUpperCase());
    const data = courses.map(({ assessments }) =>
      assessments.reduce(
        (total, assessment) => total + assessment.effortHours,
        0
      )
    );

    const chart = new Chart(ctx, {
      type: "bar",
      data: {
        labels,
        datasets: [
          {
            label: "Effort Hours",
            data,
            backgroundColor: "#89b8bb",
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          title: {
            display: true,
            text: "Courses Effort Hours",
            font: {
              size: 18,
            },
          },
          legend: {
            display: false,
          },
        },
        scales: {
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: "Effort Hours",
            },
            max: Math.max(...data) + 5,
          },
          x: {
            title: {
              display: true,
              text: "Courses",
            },
            // categoryPercentage: 0.6,
            // barPercentage: 0.8
          },
        },
      },
    });

    return () => {
      chart.destroy();
    };
  }, [courses]);

  return loading ? (
    <Loading></Loading>
  ) : (
    <div>
      <h2 id="summary-report-title">Courses Workload Summary Report</h2>

      <table>
        <thead>
          <tr>
            <th rowSpan="2">Course</th>
            <th rowSpan="2">Course Name</th>
            <th colSpan="4">Number of</th>
            <th rowSpan="2">Number of Assessments</th>
            <th rowSpan="2">Total Effort Hours</th>
          </tr>
          <tr>
            <th>Homework</th>
            <th>Quizzes</th>
            <th>Project Phases</th>
            <th>Exams</th>
          </tr>
        </thead>
        <tbody>
          {courses.map(({ course, assessments }, index) => (
            <tr key={index}>
              <td>{course.code.toUpperCase()}</td>
              <td>{course.title}</td>
              <td>{assessments.filter((a) => a.type === "hw").length}</td>
              <td>{assessments.filter((a) => a.type === "quiz").length}</td>
              <td>{assessments.filter((a) => a.type === "project").length}</td>
              <td>
                {
                  assessments.filter(
                    (a) => a.type === "midterm" || a.type === "final"
                  ).length
                }
              </td>
              <td>{assessments.length}</td>
              <td>
                {assessments.reduce(
                  (total, assessment) => total + assessment.effortHours,
                  0
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="chart-container">
        <canvas ref={chartRef}></canvas>
      </div>
    </div>
  );
}
