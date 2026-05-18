import prisma from "@/lib/prisma";

class SectionRepo {
  async getSectionById(sectionCRN) {
    const section = await prisma.section.findUnique({
      where: { crn: sectionCRN },
      include: {
        instructor: true,
        semester: true,
      },
    });
    return section;
  }

  async getSections(user, semesterId) {
    console.log("SectionRepo.getSections - Semester ID:", semesterId);

    if (!user) return [];

    // student
    if (user.isStudent) {
      const student = await prisma.user.findUnique({
        where: { id: user.id },
        include: {
          registeredSections: {
            where: { semesterId: semesterId },
            include: {
              instructor: true,
              semester: true,
            },
          },
        },
      });
      return student?.registeredSections || [];
    }

    // instructor
    if (user.isInstructor) {
      return await prisma.section.findMany({
        where: {
          instructorId: user.id,
          semesterId: semesterId,
        },
        include: {
          instructor: true,
          semester: true,
        },
      });
    }

    // coordinator
    if (user.isCoordinator) {
      return await prisma.section.findMany({
        where: {
          program: user.program,
          semesterId: semesterId,
        },
        include: {
          instructor: true,
          semester: true,
        },
      });
    }

    return [];
  }
}

export default new SectionRepo();
