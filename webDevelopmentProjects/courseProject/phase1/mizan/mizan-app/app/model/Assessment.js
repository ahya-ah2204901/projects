import { nanoid } from "nanoid";

export default class Assessment {
  constructor({
    id,
    courseId,
    title,
    type,
    dueDate,
    effortHours,
    weight,
    phase = null,
  }) {
    const randId = nanoid(8);
    this.id = id || `${courseId}-${randId}`; // courseId-[random] if not passed
    this.courseId = courseId;
    this.title = title;
    this.type = type; // 'hw', 'quiz', 'midterm', 'final', or 'project'
    this.dueDate = new Date(dueDate);
    this.effortHours = effortHours; // 1 - 10
    this.weight = weight; //  1 - 100 inclusive
    this.phase = phase; // only applicable to projcts, otherwise null
  }
}
