import prisma from "@/lib/prisma";

export async function getSemesters() {
  return await prisma.semester.findMany();
}

export async function getDefaultSemesterId() {
  const def = await prisma.semester.findFirst({ where: { isDefault: true } });
  return def?.id || null;
}
