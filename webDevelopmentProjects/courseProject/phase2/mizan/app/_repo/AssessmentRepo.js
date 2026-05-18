import prisma from "@/lib/prisma";
import sectionRepo from "@/app/_repo/SectionRepo";
import { capitalize } from "@/app/actions/utils";

class AssessmentRepo {
  async getAssessmentTypes() {
    return await prisma.assessmentType.findMany();
  }

  async getAssessmentById(id) {
    const assessment = await prisma.assessment.findUnique({
      where: { id: parseInt(id) },
      include: {
        section: {
          include: {
            instructor: true,
            semester: true,
          },
        },
        type: true,
      },
    });
    return assessment;
  }

  async getAssessmentsBySection(sectionCRN) {
    const assessments = await prisma.assessment.findMany({
      where: { sectionCRN: sectionCRN },
      include: {
        section: {
          include: {
            instructor: true,
            semester: true,
          },
        },
        type: true,
      },
    });
    return assessments;
  }

  //! type obj or string ??? (test later)
  async countAssessmentsByType(sectionCRN, type) {
    const assessments = await prisma.assessment.findMany({
      where: { sectionCRN: sectionCRN, typeId: type.toLowerCase() },
    });
    return assessments.length;
  }

  async countAssessmentsByDueDate(sectionCRN, dueDate) {
    const iso =
      typeof dueDate === "string" ? dueDate : new Date(dueDate).toISOString();
    const datePart = iso.split("T")[0]; // get "YYYY-MM-DD"

    const startOfDay = new Date(`${datePart}T00:00:00.000Z`);
    const endOfDay = new Date(`${datePart}T23:59:59.999Z`);

    const assessments = await prisma.assessment.findMany({
      where: {
        sectionCRN: sectionCRN,
        dueDate: {
          gte: startOfDay,
          lte: endOfDay,
        },
      },
    });
    console.log("LENGTH : " + assessments.length);
    return assessments.length;
  }

  async #getUserAssessments(user, semesterId) {
    const userSections = await sectionRepo.getSections(user, semesterId);
    const crns = userSections.map((section) => section.crn);
    if (crns.length === 0) return [];

    const assessments = await prisma.assessment.findMany({
      where: {
        sectionCRN: {
          in: crns,
        },
      },
      include: {
        section: true,
        type: true,
      },
    });
    return assessments;
  }

  async getAssessments(user, semesterId, sectionCRN) {
    if (!user && (!sectionCRN || sectionCRN === "all")) return [];

    const assessments =
      sectionCRN && sectionCRN !== "all"
        ? await this.getAssessmentsBySection(sectionCRN)
        : await this.#getUserAssessments(user, semesterId);

    // Sort by section CRN
    assessments.sort((a, b) => a.sectionCRN.localeCompare(b.sectionCRN));

    return assessments;
  }

  async addAssessment(assessment) {
    const { id, type, dueDate, ...assessmentData } = assessment;
    assessmentData.typeId = type;
    assessmentData.dueDate = new Date(dueDate);
    return await prisma.assessment.create({ data: assessmentData });
  }

  async updateAssessment(updatedAssessment) {
    const { type, dueDate, ...assessmentData } = updatedAssessment;
    assessmentData.typeId = type;
    assessmentData.dueDate = new Date(dueDate);
    return await prisma.assessment.update({
      where: { id: parseInt(updatedAssessment.id) },
      data: assessmentData,
    });
  }

  async deleteAssessment(id) {
    return prisma.assessment.delete({ where: { id: parseInt(id) } });
  }

  async generateAssessmentTitle(sectionCRN, type) {
    const count = (await this.countAssessmentsByType(sectionCRN, type)) + 1;
    return type === "project"
      ? `Project Phase ${count}`
      : `${capitalize(type)} ${count}`;
  }

  async getAssessmentSummary(user, semesterId) {
    const userSections = await sectionRepo.getSections(user, semesterId);
    const crns = userSections.map((s) => s.crn);
    if (crns.length === 0) return [];

    const summary = await prisma.assessment.groupBy({
      by: ["sectionCRN", "typeId"],
      where: {
        sectionCRN: { in: crns },
      },
      _count: {
        _all: true,
      },
      _sum: {
        effortHours: true,
      },
    });

    // enrich with course name
    const enriched = await Promise.all(
      summary.map(async (s) => {
        const section = await prisma.section.findUnique({
          where: { crn: s.sectionCRN },
          select: { courseCode: true, courseName: true },
        });

        return {
          sectionCRN: s.sectionCRN,
          courseName: `${section.courseCode} - ${section.courseName}`,
          type: s.typeId,
          count: s._count._all,
          effortHours: s._sum.effortHours || 0,
        };
      })
    );

    return enriched;
  }
}

export default new AssessmentRepo();
