import { nanoid } from "nanoid";

export default class User {
  constructor({
    id = nanoid(4),
    name,
    email,
    password,
    role,
    program,
    enrolledCourseIds = [],
  }) {
    this.id = id; // [randomly generated] if not passed
    this.name = name;
    this.email = email;
    this.password = password;
    this.role = role; // 'i', 's', or 'c'
    this.program = program; // example: 'CS, 'CE', ...
    this.enrolledCourseIds = enrolledCourseIds; // only applicable to students
  }

  isStudent() {
    return this.role === "s";
  }

  isInstructor() {
    return this.role === "i";
  }

  isCoordinator() {
    return this.role === "c";
  }
}
