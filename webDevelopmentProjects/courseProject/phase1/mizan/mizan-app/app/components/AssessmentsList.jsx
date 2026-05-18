"use client";
import React, { useState, useEffect } from "react";
import Select from "react-select";
import Assessment from "@/app/model/Assessment";
import User from "@/app/model/User";
import Loading from "./Loading";
import { useRouter, usePathname } from "next/navigation";

export default function AssessmentsList() {
  const [assessments, setAssessments] = useState([]);
  const [user, setUser] = useState(null);
  const [courseOptions, setCourseOptions] = useState([]);
  const [semOptions, setSemOptions] = useState([]);
  const [selectedCourses, setSelectedCourses] = useState([]);
  const [selectedSem, setSelectedSem] = useState(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    const userData = JSON.parse(localStorage.getItem("user"));
    const currentUser = new User(userData);
    setUser(currentUser);
    fetchingSemOptions();
  }, []);

  useEffect(() => {
    const currentSem = JSON.parse(localStorage.getItem("currentSem"));
    const currentSemLabel = JSON.parse(localStorage.getItem("currentSemLabel"));
    setSelectedSem({ value: currentSem, label: currentSemLabel });
    fetchingAssessments();
    fetchingCourseIds();
  }, [semOptions, user]);

  useEffect(() => {
    fetchingAssessments();
    fetchingCourseIds();
  }, [selectedSem]);

  const fetchingAssessments = async (e) => {
    try {
      const currentCourse = JSON.parse(localStorage.getItem("currentCourse"));
      // const currentSem = JSON.parse(localStorage.getItem("currentSem"));

      const fetchingURL = pathname.includes("/home/courses/course/assessments")
        ? `/api/semesters/${selectedSem.value}/courses/${currentCourse.id}/assessments`
        : `/api/semesters/${selectedSem.value}/courses/assessments?userId=${user.id}`;
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
    } finally {
      setLoading(false);
    }
  };

  const fetchingCourseIds = async (e) => {
    try {
      // const currentSem = JSON.parse(localStorage.getItem("currentSem"));
      const response = await fetch(
        `/api/semesters/${selectedSem.value}/courses?userId=${user.id}`,
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

  const fetchingSemOptions = async (e) => {
    try {
      const response = await fetch(`/api/semesters`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
      });

      const data = await response.json();

      if (!data.error) {
        const mappedSemLabels = data.map((s) => ({
          value: s.id,
          label: s.label,
        }));
        setSemOptions(mappedSemLabels);
        console.log(semOptions);
      } else {
        console.error(data.error);
      }
    } catch (err) {
      console.error(err);
    }
  };

  function handleAddUpdate() {
    if (pathname.includes("home/courses/course/assessments")) {
      router.push("/home/courses/course/assessments/addUpdate", undefined, {
        shallow: true,
      });
    }
    if (pathname.includes("home/assessments")) {
      router.push("/home/assessments/addUpdate", undefined, {
        shallow: true,
      });
    }
  }

  async function handleDelete(courseId, assessmentId) {
    if (!confirm("Are you sure you want to delete this assessment?")) return;
    const response = await fetch(
      `/api/semesters/${selectedSem.value}/courses/${courseId}/assessments/${assessmentId}`,
      {
        method: "DELETE",
      }
    );
    fetchingAssessments();
  }

  async function handleCourseFilterChange(selectedValues) {
    setSelectedCourses(selectedValues);
  }

  async function handleSemFilterChange(selectedValue) {
    setSelectedSem(selectedValue);
    setSelectedCourses([]);
  }

  const getCourseLabel = (id) => {
    const match = courseOptions.find((opt) => opt.value === id);
    return match ? match.label : id;
  };

  // filter the assessments based on the courses dropdown
  const filteredAssessments = assessments.filter((a) => {
    return selectedCourses.length === 0
      ? true
      : selectedCourses.some((c) => c.value === a.courseId);
  });

  // group the assessments by course
  const groupedAssessments = filteredAssessments.reduce((groups, a) => {
    if (!groups[a.courseId]) {
      groups[a.courseId] = [];
    }
    groups[a.courseId].push(a);
    return groups;
  }, {});

  Object.keys(groupedAssessments).forEach((courseId) => {
    groupedAssessments[courseId].sort(
      (a, b) => new Date(a.dueDate) - new Date(b.dueDate)
    );
  });

  if (loading) return <Loading></Loading>;

  return (
    <>
      <div className="assessments-top">
        {!pathname.includes("/home/courses/course/assessments") ? (
          <div className="filter-area">
            <Select
              className="filter-bar"
              id="course-multi-select"
              classNamePrefix="react-select"
              options={courseOptions}
              isMulti
              value={selectedCourses}
              onChange={handleCourseFilterChange}
              placeholder="Filter by Course.."
            />
            <Select
              className="filter-bar"
              id="sem-select"
              classNamePrefix="react-select"
              options={semOptions}
              value={selectedSem}
              onChange={handleSemFilterChange}
            />
          </div>
        ) : null}
        {user?.isInstructor() ? (
          <div className="floating-button">
            <button
              onClick={() => {
                localStorage.assessmentFormMode = "add";
                localStorage.assessmentToUpdate = JSON.stringify({});
                handleAddUpdate();
              }}
            >
              Add Assessment
            </button>
          </div>
        ) : null}
      </div>
      {filteredAssessments.length === 0 ? (
        <div className="no-assessments">
          <h4>No assessments found!</h4>
        </div>
      ) : (
        Object.entries(groupedAssessments).map(([courseId, assessments]) => (
          <div className="course-group" key={courseId}>
            <h3>{getCourseLabel(courseId)}</h3>

            {assessments.map((a, index) => {
              return (
                <div className="list-card card-w-btns" key={index}>
                  <div className="list-card-details">
                    <div id="assessment-details">
                      <div id="tags">{String(a.type).toUpperCase()}</div>
                      <div id="tags">{a.weight}%</div>
                      <div id="tags">{a.effortHours} Effort Hour(s)</div>
                    </div>
                    <h4 id="assessmentlist-title">{a.title}</h4>
                    <p id="assessment-due-date" className="subhead">
                      Due on {new Date(a.dueDate).toLocaleDateString()}
                    </p>
                  </div>

                  {user?.isInstructor() ? (
                    <div className="buttons-row">
                      <button
                        className="assessment-button upd"
                        onClick={() => {
                          localStorage.assessmentFormMode = "update";
                          localStorage.assessmentToUpdate = JSON.stringify(a);
                          handleAddUpdate();
                        }}
                      >
                        <i className="bi bi-pen"></i> <p>Update</p>
                      </button>
                      <button
                        className="assessment-button del"
                        onClick={() => handleDelete(a.courseId, a.id)}
                      >
                        <i className="bi bi-trash3"></i> <p>Delete</p>
                      </button>
                    </div>
                  ) : null}
                </div>
              );
            })}
          </div>
        ))
      )}
    </>
  );
}
