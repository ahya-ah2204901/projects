import fs from "fs-extra";
import path from "path";
import User from "@/app/model/User";
import Assessment from "@/app/model/Assessment";
import courseRepo from "@/app/repo/CourseRepo";

class AssessmentRepo {
  constructor() {
    this.courseFilePath = path.join(process.cwd(), "app/data/courses.json");
    this.userFilePath = path.join(process.cwd(), "app/data/users.json");
    this.assessmentFilePath = path.join(
      process.cwd(),
      "app/data/assessments.json"
    );
  }

  async getAssessmentById(assessmentId) {
    const assessments = await fs.readJson(this.assessmentFilePath);
    return assessments.find((a) => a.id === assessmentId);
  }

  async getAssessmentsByCourse(courseId) {
    const assessments = await fs.readJson(this.assessmentFilePath);
    return assessments.filter((a) => a.courseId === courseId);
  }

  async getAssessmentsByUserBySem(userId, semId, topDue = null) {
    const userCourses = await courseRepo.getCoursesByUserBySem(userId, semId);
    const userCoursesIds = userCourses.map((c) => c.id);
    const assessments = await fs.readJson(this.assessmentFilePath);
    const userAssessments = assessments.filter((a) =>
      userCoursesIds.includes(a.courseId)
    );
    return topDue
      ? userAssessments
          .filter((a) => new Date(a.dueDate) > new Date())
          .sort((a, b) => new Date(a.dueDate) - new Date(b.dueDate))
          .slice(0, parseInt(topDue))
      : userAssessments;
  }

  async addAssessment(assessment) {
    const allAssessments = await fs.readJson(this.assessmentFilePath);
    const courseAssessments = await this.getAssessmentsByCourse(
      assessment.courseId
    );

    // only one final exam
    if (
      assessment.type === "final" &&
      courseAssessments.some((a) => a.type === "final")
    ) {
      throw new Error("Only one final exam is allowed per course.");
    }

    // at most 2 midterms
    if (
      assessment.type === "midterm" &&
      courseAssessments.filter((a) => a.type === "midterm").length >= 2
    ) {
      throw new Error("At most two midterm exams are allowed per course.");
    }

    if (
      courseAssessments.some(
        (a) =>
          new Date(a.dueDate).toISOString().split("T")[0] ===
          new Date(assessment.dueDate).toISOString().split("T")[0]
      )
    ) {
      throw new Error("Another assessment already has this due date.");
    }

    // phase between 1 and 4 (for projects), also sequential phases and date validation
    if (assessment.type === "project") {
      const existingPhases = courseAssessments
        .filter((a) => a.type === "project")
        .map((a) => a.phase);

      if (existingPhases.includes(assessment.phase)) {
        throw new Error(`Phase ${assessment.phase} already exists.`);
      }

      const maxPhase =
        existingPhases.length > 0 ? Math.max(...existingPhases) : 0;
      if (assessment.phase !== maxPhase + 1) {
        throw new Error(
          `Next phase must be ${maxPhase + 1}. You tried to add Phase ${
            assessment.phase
          }.`
        );
      }

      if (assessment.phase > 1) {
        const previousPhase = courseAssessments.find(
          (a) => a.type === "project" && a.phase === assessment.phase - 1
        );

        if (
          previousPhase &&
          new Date(assessment.dueDate) <= new Date(previousPhase.dueDate)
        ) {
          throw new Error(
            `Phase ${assessment.phase} must be due after Phase ${
              assessment.phase - 1
            } (${new Date(previousPhase.dueDate).toISOString().split("T")[0]}).`
          );
        }
      }
    }

    // max 8 homework
    if (
      assessment.type === "hw" &&
      courseAssessments.filter((a) => a.type === "hw").length >= 8
    ) {
      throw new Error("Maximum 8 homework assignments allowed per course.");
    }

    if (!assessment.title) {
      const sameType = courseAssessments.filter(
        (a) => a.type === assessment.type
      );
      const count = sameType.length + 1;
      if (assessment.type !== "project") {
        console.log("NOT PROJECT");
        assessment.title = `${capitalize(assessment.type)} ${count}`;
      } else {
        assessment.title = `${capitalize(assessment.type)} Phase ${
          assessment.phase
        }`;
      }
    }

    const newAssessment = new Assessment(assessment);

    allAssessments.push(newAssessment);
    await fs.writeJSON(this.assessmentFilePath, allAssessments);
    return assessment;
  }

  async updateAssessment(assessmentId, assessment) {
    const assessments = await fs.readJson(this.assessmentFilePath);
    const courseAssessments = await this.getAssessmentsByCourse(
      assessment.courseId
    );
    const index = assessments.findIndex((a) => a.id === assessmentId);
    if (index >= 0) {
      if (!assessment.title || assessment.title.trim() === "") {
        // title not allowed to be blank when updating
        throw new Error("Title is required when updating an assessment.");
      }

      if (
        courseAssessments.some(
          (a) =>
            a.id !== assessmentId &&
            new Date(a.dueDate).toISOString().split("T")[0] ===
              new Date(assessment.dueDate).toISOString().split("T")[0]
        )
      ) {
        throw new Error("Another assessment already has this due date.");
      }

      assessment.id = assessmentId; // to ensure no its not lost
      assessment.courseId = assessments[index].courseId; // to ensure no its not lost
      assessments[index] = assessment;
      await fs.writeJson(this.assessmentFilePath, assessments);
      return assessment;
    }
    throw new Error("Cannot update assessment — doesn't exist");
  }

  async deleteAssessment(assessmentId) {
    const assessments = await fs.readJson(this.assessmentFilePath);
    const existingAssessment = assessments.find((a) => a.id === assessmentId);
    if (!existingAssessment) {
      throw new Error("Assessment not found");
    }
    const allExceptToDelete = assessments.filter((a) => a.id !== assessmentId);
    await fs.writeJson(this.assessmentFilePath, allExceptToDelete);
    return existingAssessment;
  }
}

function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

export default new AssessmentRepo();
