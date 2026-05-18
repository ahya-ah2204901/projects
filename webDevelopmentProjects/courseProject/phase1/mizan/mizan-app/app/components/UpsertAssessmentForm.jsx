"use client";
import React, { useState, useEffect } from "react";
import User from "@/app/model/User";
import { useRouter, usePathname } from "next/navigation";
import Select from "react-select";

export default function UpsertAssessmentForm() {
  const [user, setUser] = useState(null);
  const [mode, setMode] = useState(null);

  const [semOptions, setSemOptions] = useState([]);
  const [selectedSem, setSelectedSem] = useState(null);

  const [courseOptions, setCourseOptions] = useState([]);
  const [selectedCourse, setSelectedCourse] = useState(null);

  const [currentAssessment, setCurrentAssessment] = useState({});

  const router = useRouter();
  const pathname = usePathname();

  // -------------------------------------------------------------------------------

  useEffect(() => {
    const userData = JSON.parse(localStorage.getItem("user"));
    const mode = localStorage.getItem("assessmentFormMode");
    const currentAssessment = JSON.parse(
      localStorage.getItem("assessmentToUpdate")
    );

    setMode(mode);
    setUser(new User(userData));

    if (!currentAssessment || Object.keys(currentAssessment).length === 0) {
      console.log("empty");

      const nextWeekDate = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
        .toISOString()
        .split("T")[0];
      setCurrentAssessment({
        courseId: "",
        title: "",
        type: "hw",
        dueDate: nextWeekDate,
        effortHours: 1,
        weight: 10,
        phase: null,
      });
    } else {
      setCurrentAssessment(currentAssessment);
    }

    fetchSemOptions();
  }, []);

  useEffect(() => {
    if (mode === "update") {
      const sem = currentAssessment.courseId.split("-")[1];
      const found = semOptions.find((s) => s.value === sem);
      setSelectedSem(found);
    } else if (pathname.includes("/home/courses/course/assessments")) {
      const currSem = JSON.parse(localStorage.getItem("currentSem"));
      const currSemLabel = JSON.parse(localStorage.getItem("currentSemLabel"));
      setSelectedSem({ value: currSem, label: currSemLabel });
    }
    fetchCourseIds();
  }, [semOptions, user, mode]);

  useEffect(() => {
    if (mode === "update") {
      const course = currentAssessment.courseId;
      const found = courseOptions.find((c) => c.value === course);
      setSelectedCourse(found);
    } else if (pathname.includes("/home/courses/course/assessments")) {
      const currCourse = JSON.parse(localStorage.getItem("currentCourse"));
      setSelectedCourse({
        value: currCourse.id,
        label: currCourse.code.toUpperCase(),
      });
    }
  }, [courseOptions]);

  useEffect(() => {
    fetchCourseIds();
  }, [selectedSem]);

  // -------------------------------------------------------------------------------

  const fetchSemOptions = async (e) => {
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
      } else {
        console.error(data.error);
      }
    } catch (err) {
      console.error(err);
    }
  };

  // -------------------------------------------------------------------------------

  const fetchCourseIds = async (e) => {
    // if the sem is not yet selected
    if (!selectedSem) {
      setCourseOptions([{ value: "test", label: "test" }]);
      return;
    }
    // if the sem is selected
    try {
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

  // -------------------------------------------------------------------------------

  const handleSemFilterChange = async (e) => {
    setSelectedSem(e);
    setSelectedCourse(null);
  };

  // -------------------------------------------------------------------------------

  const handleCourseFilterChange = async (e) => {
    setSelectedCourse(e);
  };

  // -------------------------------------------------------------------------------

  const handleSubmit = async (assessmentToSubmit) => {
    try {
      const url =
        mode === "update"
          ? `/api/semesters/${selectedSem?.value}/courses/${selectedCourse?.value}/assessments/${currentAssessment.id}`
          : `/api/semesters/${selectedSem?.value}/courses/${selectedCourse?.value}/assessments`;
      console.log(url);

      const method = mode === "update" ? "PUT" : "POST";

      const response = await fetch(url, {
        method: method,
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(assessmentToSubmit),
      });

      const result = await response.json();
      if (result.error) {
        alert("Error: " + result.error);
      } else {
        // alert(
        //   `Assessment ${mode === "update" ? "updated" : "added"} successfully`
        // )
        router.back();
      }
    } catch (err) {
      console.error(err);
      alert("Something went wrong.");
    }
  };

  // -------------------------------------------------------------------------------

  return (
    <div className="form-container">
      <h2>{mode === "update" ? "Update" : "Add"} Assessment</h2>
      <form id="assessment-form" className="assessment-form">
        {/* <label htmlFor="title-input">Semester and Course</label> */}
        <di className="filter-area">
          <Select
            required
            className="filter-bar"
            classNamePrefix="react-select"
            options={semOptions}
            value={selectedSem}
            placeholder="Select Semester.."
            onChange={(e) => {
              handleSemFilterChange(e);
            }}
            isDisabled={
              pathname.includes("/home/courses/course/assessments") ||
              mode === "update"
            }
          />
          <Select
            required
            className="filter-bar"
            classNamePrefix="react-select"
            options={courseOptions}
            value={selectedCourse}
            onChange={(e) => {
              handleCourseFilterChange(e);
              setCurrentAssessment({
                ...currentAssessment,
                courseId: e.value,
              });
            }}
            isDisabled={
              pathname.includes("/home/courses/course/assessments") ||
              mode === "update"
            }
            placeholder="Select Course.."
          />
        </di>
        <label htmlFor="title-input">Title</label>
        <input
          id="title-input"
          type="text"
          name="title"
          value={currentAssessment.title || ""}
          onChange={(e) =>
            setCurrentAssessment({
              ...currentAssessment,
              title: e.target.value,
            })
          }
        />
        <div className="assessmentTypeDropbox">
          <label>Assessment Type</label>
          <select
            name="type"
            value={currentAssessment.type || "hw"}
            onChange={(e) =>
              setCurrentAssessment({
                ...currentAssessment,
                type: e.target.value,
              })
            }
            readOnly={mode === "update"}
          >
            <option value="" disabled>
              Select Phase
            </option>
            <option value="hw">Homework</option>
            <option value="quiz">Quiz</option>
            <option value="midterm">Midterm</option>
            <option value="final">Final</option>
            <option value="project">Project</option>
          </select>

          {currentAssessment.type === "project" ? (
            <>
              <label>Phase</label>
              <select
                name="phase"
                value={currentAssessment.phase ?? ""}
                onChange={(e) =>
                  setCurrentAssessment({
                    ...currentAssessment,
                    phase: Number(e.target.value),
                  })
                }
                required
                readOnly={mode === "update"}
              >
                <option value="" disabled>
                  Select Phase
                </option>
                <option value={1}>Phase 1</option>
                <option value={2}>Phase 2</option>
                <option value={3}>Phase 3</option>
                <option value={4}>Phase 4</option>
              </select>
            </>
          ) : null}
        </div>
        <label htmlFor="effort-input">Effort Hours</label>
        <input
          id="effort-input"
          type="number"
          min={1}
          max={10}
          name="effortHours"
          value={currentAssessment.effortHours || 1}
          onChange={(e) =>
            setCurrentAssessment({
              ...currentAssessment,
              effortHours: Number(e.target.value),
            })
          }
        />
        <label htmlFor="weight-input">Weight</label>
        <input
          id="weight-input"
          type="number"
          min={1}
          max={100}
          name="weight"
          value={currentAssessment.weight || 10}
          onChange={(e) =>
            setCurrentAssessment({
              ...currentAssessment,
              weight: Number(e.target.value),
            })
          }
        />
        <label htmlFor="due-date-input">Due Date</label>
        <input
          id="due-date-input"
          type="date"
          min={
            mode === "update"
              ? new Date(currentAssessment.dueDate).toISOString().split("T")[0] // old date onwards only
              : new Date().toISOString().split("T")[0] // today onwards only
          }
          name="dueDate"
          value={
            currentAssessment.dueDate
              ? new Date(currentAssessment.dueDate).toISOString().split("T")[0]
              : ""
          }
          onChange={(e) =>
            setCurrentAssessment({
              ...currentAssessment,
              dueDate: e.target.value,
            })
          }
        />
        <button type="button" className="back" onClick={router.back}>
          Cancel
        </button>

        <button
          className="add-assessment"
          type="button"
          onClick={(e) => {
            if (!selectedSem) {
              alert("Please select a semester.");
              return;
            }

            if (!selectedCourse) {
              alert("Please select a course.");
              return;
            }

            const form = document.getElementById("assessment-form");
            const formData = new FormData(form);
            const assessment = {
              courseId: selectedCourse?.value,
              title: formData.get("title"),
              type: formData.get("type"),
              dueDate: formData.get("dueDate"),
              effortHours: Number(formData.get("effortHours")),
              weight: Number(formData.get("weight")),
              phase: formData.get("phase")
                ? Number(formData.get("phase"))
                : undefined,
            };
            console.log(assessment);

            handleSubmit(assessment);
          }}
        >
          {mode === "update" ? "Update" : "Add"} Assessment
        </button>
      </form>
    </div>
  );
}
