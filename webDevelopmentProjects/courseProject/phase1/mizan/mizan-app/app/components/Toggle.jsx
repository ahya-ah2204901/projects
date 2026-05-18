"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";

export default function Toggle() {
  const pathname = usePathname();

  let classAssesName;
  switch (pathname) {
    case "/home/courses/course":
      classAssesName = "link";
      break;
    case "/home/courses/course/assessments":
      classAssesName = "link-active";
      break;
    case "/home/courses/course/comments":
      classAssesName = "link";
      break;
  }
  let classCommName;
  switch (pathname) {
    case "/home/courses/course":
      classCommName = "link";
      break;
    case "/home/courses/course/assessments":
      classCommName = "link";
      break;
    case "/home/courses/course/comments":
      classCommName = "link-active";
      break;
  }

  return (
    <nav id="navigation">
      <div id="toggle">
        <ul>
          <li>
            <Link
              href="/home/courses/course/assessments"
              id="assessments"
              className={classAssesName}
            >
              Assessments
            </Link>
          </li>
          <li>
            <Link
              href="/home/courses/course/comments"
              id="assessments"
              className={classCommName}
            >
              Comments
            </Link>
          </li>
        </ul>
      </div>
    </nav>
  );
}