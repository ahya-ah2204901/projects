import fs from "fs-extra";
import path from "path";
import Semester from "@/app/model/Semester";

class SemesterRepo {
  constructor() {
    this.semFilePath = path.join(process.cwd(), "app/data/semesters.json");
  }

  async getAllSemesters() {
    const semesters = await fs.readJson(this.semFilePath);
    return semesters.map((s) => new Semester(s));
  }

  async getSemesterById(semId) {
    const semesters = await this.getAllSemesters();
    return semesters.find((s) => s.id === semId);
  }
}

export default new SemesterRepo();
