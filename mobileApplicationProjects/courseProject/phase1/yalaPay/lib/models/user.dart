class User {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  User({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        email: map['email'],
        password: map['password'],
        firstName: map['firstName'],
        lastName: map['lastName']);
  }
}
