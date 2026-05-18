"use client";
import React from "react";
import { usePathname } from "next/navigation";
import Toggle from "@/app/components/Toggle";

export default function CoursesLayout({ children }) {
  function setToggleVisible() {
    return usePathname() != "/home/courses/course/assessments/addUpdate" ? (
      <Toggle></Toggle>
    ) : null;
  }

  return (
    <div className="outer-div">
      <div id="toggle-div">{setToggleVisible()}</div>
      {children}
    </div>
  );
}
