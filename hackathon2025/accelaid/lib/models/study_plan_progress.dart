// import 'package:accelaid/models/competency_progress.dart';
//
// class StudyPlanProgress {
//   final String sppId;
//   final String stId;
//   List<CompetencyProgress> competencyProgresses;
//
//   StudyPlanProgress({
//     required this.sppId,
//     required this.stId,
//     required this.competencyProgresses,
//   });
//
//   factory StudyPlanProgress.fromMap(Map<String, dynamic> map) {
//     return StudyPlanProgress(
//       sppId: map['sppId'] as String,
//       stId: map['stId'] as String,
//       competencyProgresses: (map['competencyProgresses'] as List)
//           .map((e) => CompetencyProgress.fromMap(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'sppId': sppId,
//       'stId': stId,
//       'competencyProgresses':
//           competencyProgresses.map((e) => e.toMap()).toList(),
//     };
//   }
// }
