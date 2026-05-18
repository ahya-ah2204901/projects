import { PrismaClient } from "@prisma/client";
import path from "path";
import fs from "fs-extra";

const basePath = path.join(process.cwd(), "data");

async function main() {
  const prisma = new PrismaClient();
  await prisma.assessmentType.deleteMany();
  await prisma.semester.deleteMany();
  try {
    await seedSemesters(prisma);
    await seedAssessmentTypes(prisma);
    await seedCoordinators(prisma);
    await seedInstructors(prisma);
    await seedSections(prisma);
    await seedStudents(prisma);
    await seedAssessments(prisma);
    await seedComments(prisma);
  } catch (e) {
    console.error(e);
    throw e;
  } finally {
    await prisma.$disconnect();
  }
}

async function seedSemesters(prisma) {
  const semestersFilePath = path.join(basePath, "semesters.json");
  const semesters = await fs.readJSON(semestersFilePath);
  for (const sem of semesters) {
    console.log("Creating semester:", sem);
    await prisma.semester.create({ data: sem });
  }
}

async function seedAssessmentTypes(prisma) {
  const assessmentTypesFilePath = path.join(basePath, "assessment-types.json");
  const assessmentTypes = await fs.readJSON(assessmentTypesFilePath);
  for (const type of assessmentTypes) {
    console.log("Creating assessment type:", type);
    await prisma.assessmentType.create({ data: type });
  }
}

async function seedCoordinators(prisma) {
  const usersFilePath = path.join(basePath, "users.json");
  const users = await fs.readJSON(usersFilePath);
  const coordinators = users.filter((user) => user.role === "Coordinator");
  for (const coordinator of coordinators) {
    console.log("Creating coordinator:", coordinator);
    await prisma.user.upsert({
      where: { email: coordinator.email },
      update: {},
      create: coordinator,
    });
  }
}

async function seedInstructors(prisma) {
  const usersFilePath = path.join(basePath, "users.json");
  const users = await fs.readJSON(usersFilePath);
  const instructors = users.filter((user) => user.role == "Instructor");
  for (const instructor of instructors) {
    console.log("Creating instructor:", instructor);
    await prisma.user.upsert({
      where: { email: instructor.email },
      update: {},
      create: instructor,
    });
  }
}

async function seedSections(prisma) {
  const sectionsFilePath = path.join(basePath, "sections.json");
  const sections = await fs.readJSON(sectionsFilePath);
  for (const section of sections) {
    console.log("Creating section:", section);
    const { semester, ...rest } = section;
    await prisma.section.upsert({
      where: { crn: section.crn },
      update: {},
      create: {
        ...rest,
        semesterId: semester,
      },
    });
  }
}

async function seedStudents(prisma) {
  const usersFilePath = path.join(basePath, "users.json");
  const users = await fs.readJSON(usersFilePath);
  const students = users.filter((user) => user.role == "Student");
  for (const student of students) {
    console.log("Creating student:", student);
    const { registeredSections, ...userData } = student;
    await prisma.user.upsert({
      where: { email: student.email },
      update: {},
      create: {
        ...userData,
        registeredSections: {
          connect: registeredSections,
        },
      },
    });
  }
}

async function seedAssessments(prisma) {
  const assessmentsFilePath = path.join(basePath, "assessments.json");
  const assessments = await fs.readJSON(assessmentsFilePath);
  for (const assessment of assessments) {
    console.log("Creating assessment:", assessment);
    const { type, ...assessmentData } = assessment;
    assessmentData.typeId = type;
    assessmentData.dueDate = new Date(assessmentData.dueDate);
    await prisma.assessment.upsert({
      where: { id: assessment.id },
      update: {},
      create: assessmentData,
    });
  }
}

async function seedComments(prisma) {
  const commentsFilePath = path.join(basePath, "comments.json");
  const comments = await fs.readJSON(commentsFilePath);
  for (const comment of comments) {
    console.log("Creating comment:", comment);
    comment.createdDate = new Date(comment.createdDate);
    await prisma.comment.upsert({
      where: { id: comment.id },
      update: {},
      create: comment,
    });
  }
}

await main();
