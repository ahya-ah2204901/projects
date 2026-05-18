class Teacher {
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String school;

  Teacher(
      {required this.email,
      required this.firstName,
      required this.lastName,
      required this.phone,
      required this.school});

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phone: map['phone'],
      school: map['school'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'firstNameLower': firstName.toLowerCase(),
      'lastNameLower': lastName.toLowerCase(),
      'phone': phone,
      'school': school,
    };
  }
}
