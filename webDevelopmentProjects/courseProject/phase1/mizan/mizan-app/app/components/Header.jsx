"use client";
import React, { use } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";

export default function ShellHeader() {
  const pathname = usePathname();
  const course = JSON.parse(localStorage.getItem("currentCourse"));
  let classN;
  const router = useRouter();

  const user = JSON.parse(localStorage.user);
  const date = new Date().toLocaleDateString("en-qa", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
  const initials = user.name
    .split(" ")
    .map((namePart) => namePart[0].toUpperCase())
    .join("");

  function getHeaderContent() {
    switch (pathname) {
      case "/home":
        classN = "";
        return (
          <>
            <h2>Welcome Back, {user.name}</h2>
            <p>{date}</p>
          </>
        );
      case "/home/courses":
        classN = "";
        return (
          <>
            <h2>Courses</h2>
            <p>{date}</p>
          </>
        );
      case "/home/courses/course":
        classN = "";
        return (
          <>
            <h2>{course.title}</h2>
            <p>{date}</p>
          </>
        );
      case "/home/courses/course/assessments":
        classN = "course-head";
        return (
          <>
            <h2>{course.title}</h2>
            <p>{date}</p>
          </>
        );
      case "/home/courses/course/comments":
        classN = "course-head";
        console.log(classN);
        return (
          <>
            <h2>{course.title}</h2>
            <p>{date}</p>
          </>
        );
      case "/home/assessments":
        classN = "";
        return (
          <>
            <h2>Assessments</h2>
            <p>{date}</p>
          </>
        );
      case "/home/reports":
        classN = "";
        return (
          <>
            <h2>Summary Report</h2>
            <p>{date}</p>
          </>
        );
      case "/home/calendar":
        classN = "";
        return (
          <>
            <h2>Calendar</h2>
            <p>{date}</p>
          </>
        );
    }
  }

  function headerClick() {
    if (
      pathname === "/home/courses/course/comments" ||
      pathname === "/home/courses/course/assessments"
    ) {
      router.push("/home/courses/course");
    }
  }

  return (
    <>
      <header>
        <div id="header-titles" className={classN} onClick={headerClick}>
          {getHeaderContent()}
        </div>

        <div id="header-userinfo">
          <i className="bi bi-bell"></i>
          <div className="user-initials">{initials}</div>
          <div>
            <h5>{user.name}</h5>
            <p>{user.email}</p>
          </div>
        </div>
      </header>
    </>
  );
}
