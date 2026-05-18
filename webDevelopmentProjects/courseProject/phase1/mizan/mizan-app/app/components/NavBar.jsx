"use client";
import React, { useState, useEffect } from "react";
import Link from "next/link";
import User from "@/app/model/User";

export default function NavBar() {
  const [user, setUser] = useState(null);
  const fetchCurrentUser = async (e) => {
    try {
      const userData = JSON.parse(localStorage.getItem("user"));
      const currentUser = new User(userData);
      setUser(currentUser);
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {
    fetchCurrentUser();
  }, []);

  return (
    <nav className="navBar">
      <ul className="navRail">
        <li>
          <Link className="nav-link" href="/home">
            <p className="nav-icon-label">Home</p>{" "}
            <i className="bi bi-house"></i>
          </Link>
        </li>
        <li>
          <Link className="nav-link" href="/home/courses">
            <p className="nav-icon-label">Courses</p>{" "}
            <i className="bi bi-backpack"></i>
          </Link>
        </li>
        <li>
          <Link className="nav-link" href="/home/assessments">
            <p className="nav-icon-label">Assessments</p>
            <i className="bi bi-journal-bookmark"></i>
          </Link>
        </li>
        {user?.isStudent() || user?.isCoordinator() ? (
          <li>
            <Link className="nav-link" href="/home/reports">
              <p className="nav-icon-label">Reports</p>
              <i className="bi bi-file-earmark-bar-graph"></i>
            </Link>
          </li>
        ) : null}
        {user?.isStudent() ? (
          <li>
            <Link className="nav-link" href="/home/calendar">
              <p className="nav-icon-label">Calendar</p>
              <i className="bi bi-calendar2-check"></i>
            </Link>
          </li>
        ) : null}
      </ul>

      <Link className="logout-icon nav-link" href="/">
        <p className="nav-icon-label">Log Out</p>
        <i className="bi bi-box-arrow-right"></i>
      </Link>
    </nav>
  );
}
