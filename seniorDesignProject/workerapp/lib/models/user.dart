class User {
  final String id;
  final String email;
  //final String password;
  final String firstName;
  final String lastName;
  final String role;
  String? supervisorId;

  User({
    required this.id,
    required this.email,
    //required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.supervisorId,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      role: map['role'],
      supervisorId: map['supervisorId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'supervisorId': supervisorId,
    };
  }
}
