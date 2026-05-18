"use client";
import React from "react";
import NavBar from "@/app/components/NavBar";
import ShellHeader from "@/app/components/Header";
import { usePathname } from "next/navigation";

export default function HomeLayout({ children }) {
  const pathname = usePathname();
  let className;
  switch (pathname) {
    case "/home":
      className = "home";
      break;
    case "/home/courses/course":
      className = "course-details";
      break;
    case "/home/courses":
      className = "courses";
      break;
  }
  return (
    <>
      <NavBar></NavBar>
      <ShellHeader></ShellHeader>
      <main className={className}>{children}</main>
    </>
  );
}
