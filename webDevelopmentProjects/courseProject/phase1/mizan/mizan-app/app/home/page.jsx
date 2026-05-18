"use client";
import React, { useState } from "react";
import AssessmentsWidget from "../components/AssessmentsWidget";
import Calendar from "react-calendar";

export default function HomePage() {
  const [date, setDate] = useState(new Date());

  const onChange = (newDate) => setDate(newDate);

  return (
    <main id="home-main">
      <div className="grid-layout">
        <section className="assessments-widget widget">
          <h2>Upcoming Assessments</h2>
          <AssessmentsWidget></AssessmentsWidget>
        </section>

        {/* <section className="count-widget widget">
          <h2>Assessment Count</h2>
        </section> */}

        <section className="course-widget widget">
          <h2> Courses</h2>
          <div>
            <p>
              <strong>Web Dev 101</strong>
              <br />
              Progress: 75%
            </p>
            <p>
              <strong>Software Engineering</strong>
              <br />
              Progress: 60%
            </p>
            <p>
              <strong>Data Structures</strong>
              <br />
              Progress: 85%
            </p>
          </div>
        </section>

        <section className="report-widget widget">
          <h2> Summary Report</h2>
          <div>
            <p>
              📊 Avg Score: <strong>89%</strong>
            </p>
            <p>
              ⏱️ Weekly Time: <strong>12 hrs</strong>
            </p>
            <p>
              ✅ Assignments: <strong>14/16</strong>
            </p>
          </div>
        </section>

        <section className="calendar-widget widget">
          <Calendar onChange={onChange} value={date} />
        </section>

        {/* <section className="comments-widget widget">
          <h2> Recent Comments</h2>
          <ul>
            <li>
              <strong>@ganna:</strong> "Guys whens Quiz 4?"
            </li>
            <li>
              <strong>@alya:</strong> "Not sure but Quiz 3 just finished so.. Maybe next week?"
            </li>
            <li>
              <strong>@carmela:</strong> "Quiz 3 was hard"
            </li>
            <li>
              <strong>@bsmalla:</strong> "Need help with the report?"
            </li>
            <li>
              <strong>@aya:</strong> "He Uploaded Assignment 1 Grades!"
            </li>
          </ul>
        </section> */}
      </div>
    </main>
  );
}
