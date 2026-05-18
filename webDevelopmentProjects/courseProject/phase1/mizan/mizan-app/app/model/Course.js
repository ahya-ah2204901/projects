export default class Course {
  constructor({
    id,
    code,
    title,
    description,
    creditHours,
    instructorId,
    program,
    sem,
  }) {
    this.id = id || `${code}-${sem}`; // [code]-[sem] if not passed
    this.code = code; // example: 'cmps350'
    this.title = title; // example: 'Web Dev Fundamentals'
    this.description = description;
    this.creditHours = creditHours;
    this.instructorId = instructorId;
    this.program = program; // example: 'CS, 'CE', ...
    this.sem = sem; // example: 'fl25', sp25', 'sm25'
  }
}
