class Student {
  String teacherEmail;
  final String stId;
  final String firstName;
  final String lastName;
  late bool hasStudyPlan;
  late double progress;
  final DateTime dob;
  final String gradeLevel;
  final String lastCompletedGradeLevel;
  late String studyPlan = 'unavailablePlan';

  Student(
      {required this.stId,
      required this.firstName,
      required this.lastName,
      required this.dob,
      required this.hasStudyPlan,
      required this.progress,
      required this.teacherEmail,
      required this.gradeLevel,
      required this.lastCompletedGradeLevel,
      required this.studyPlan});

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      stId: map['stId'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      dob: DateTime.parse(map['dob']),
      hasStudyPlan: map['hasStudyPlan'],
      progress: map['progress'],
      teacherEmail: map['teacherEmail'],
      gradeLevel: map['gradeLevel'] ?? '',
      lastCompletedGradeLevel: map['lastCompletedGradeLevel'],
      studyPlan: map['studyPlan'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stId': stId,
      'firstName': firstName,
      'lastName': lastName,
      'firstNameLower': firstName.toLowerCase(),
      'lastNameLower': lastName.toLowerCase(),
      'dob': dob.toString(),
      'hasStudyPlan': hasStudyPlan,
      'progress': progress,
      'teacherEmail': teacherEmail,
      'gradeLevel': gradeLevel,
      'lastCompletedGradeLevel': lastCompletedGradeLevel,
      'studyPlan': studyPlan
    };
  }
}
