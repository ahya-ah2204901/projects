class Competency {
  final String gradeLevel; // 1 --> 6
  final String compId; // 1,2,3,..
  final String competency;

  Competency({
    required this.gradeLevel,
    required this.compId,
    required this.competency,
  });

  factory Competency.fromMap(Map<String, dynamic> map) {
    return Competency(
      gradeLevel: map['gradeLevel'] ?? '',
      compId: map['compId'] ?? '',
      competency: map['comp'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'gradeLevel': gradeLevel,
      'compId': compId,
      'comp': competency,
    };
  }


}
