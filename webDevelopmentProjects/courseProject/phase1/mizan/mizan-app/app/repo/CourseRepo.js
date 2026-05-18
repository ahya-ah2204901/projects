import fs from "fs-extra";
import path from "path";
import Course from "@/app/model/Course";
import User from "@/app/model/User";

class CourseRepo {
  constructor() {
    this.courseFilePath = path.join(process.cwd(), "app/data/courses.json");
    this.userFilePath = path.join(process.cwd(), "app/data/users.json");
  }

  async getAllCourses() {
    // returns a list of all courses
    const courses = await fs.readJson(this.courseFilePath);
    return courses.map((c) => new Course(c));
  }

  async getCourseById(courseId) {
    const courses = await this.getAllCourses();
    return courses.find((c) => c.id === courseId);
  }

  async getCoursesByUserBySem(userId, semId) {
    const jsonUsers = await fs.readJson(this.userFilePath);
    const users = jsonUsers.map((u) => new User(u));
    const user = users.find((u) => u.id === userId);

    if (!user) return []; // should not happen though

    const allCourses = await this.getAllCourses();
    const semCourses = allCourses.filter((c) => c.sem === semId);
    console.log(semCourses.length);

    let filtered = [];

    if (user.isStudent()) {
      filtered = semCourses.filter((c) =>
        user.enrolledCourseIds.includes(c.id)
      );
      console.log("st " + filtered.length);
      return filtered;
    }

    if (user.isInstructor()) {
      filtered = semCourses.filter((c) => c.instructorId === user.id);
      console.log("in " + filtered.length);
      return filtered;
    }

    if (user.isCoordinator()) {
      filtered = semCourses.filter((c) => c.program === user.program);
      console.log("co " + filtered.length);
      return filtered;
    }

    return [];
  }
}

export default new CourseRepo();
