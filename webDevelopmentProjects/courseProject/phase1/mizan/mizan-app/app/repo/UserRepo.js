import fs from "fs-extra";
import path from "path";
import User from "@/app/model/User";

class UserRepo {
  constructor() {
    this.filePath = path.join(process.cwd(), "app/data/users.json");
  }

  async getAllUsers() {
    // returns a list of all users
    const users = await fs.readJSON(this.filePath);
    return users.map((user) => new User(user));
  }

  async getUserByEmail(email) {
    // returns user or undefined if user doesn't exist
    const users = await this.getAllUsers();
    return users.find((user) => user.email === email);
  }

  async getUserById(id) {
    // returns user or undefined if user doesn't exist
    const users = await this.getAllUsers();
    return users.find((user) => user.id === id);
  }

  async login(email, password) {
    // returns user object on success & objcet literal with error property on failure
    const user = await this.getUserByEmail(email);
    if (!user || user.password !== password)
      return { error: "Incorrect username or password." };
    return user;
  }
}

export default new UserRepo();
