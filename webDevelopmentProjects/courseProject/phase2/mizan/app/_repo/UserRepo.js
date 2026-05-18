import prisma from "@/lib/prisma";

class UserRepo {
  async getUser(id) {
    const user = await prisma.user.findUnique({ where: { id: id } });
    return user;
  }

  // Public method to authenticate a user by email and password
  async login(email, password) {
    const user = await prisma.user.findUnique({
      where: { email: email.toLowerCase() },
    });

    // Check if user exists and password matches
    if (!user || user.password !== password) {
      throw new Error("Incorrect username or password.");
    }
    // Remove password from user object for security
    delete user.password;
    user.name = `${user.firstName} ${user.lastName}`;
    user.isStudent = user.role === "Student";
    user.isInstructor = user.role === "Instructor";
    user.isCoordinator = user.role === "Coordinator";
    //!  user program as well?????
    return user;
  }
}

export default new UserRepo();
