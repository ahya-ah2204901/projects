// class StudyPlan {
//   final String planId;
//   final String stId;
//   final List<WeekPlan> weekPlans;
//
//   StudyPlan({
//     required this.planId,
//     required this.stId,
//     required this.weekPlans,
//   });
//
//   factory StudyPlan.fromMap(Map<String, dynamic> map) {
//     return StudyPlan(
//       planId: map['planId'] ?? '',
//       stId: map['studentId'] ?? '',
//       weekPlans: (map['weekPlans'] as List<dynamic>)
//           .map((weekPlan) => WeekPlan.fromMap(weekPlan))
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'planId': planId,
//       'studentId': stId,
//       'weekPlans': weekPlans.map((weekPlan) => weekPlan.toMap()).toList(),
//     };
//   }
// }
//
// // -----------------------------------------------------------------------------
//
// class WeekPlan {
//   final int weekNumber; // 1 --> 35
//   final List<TopicProgress> topics;
//
//   WeekPlan({
//     required this.weekNumber,
//     required this.topics,
//   });
//
//   factory WeekPlan.fromMap(Map<String, dynamic> map) {
//     return WeekPlan(
//       weekNumber: map['weekNumber'] ?? 0,
//       topics: (map['topics'] as List<dynamic>)
//           .map((topic) => TopicProgress.fromMap(topic))
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'weekNumber': weekNumber,
//       'topics': topics.map((topic) => topic.toMap()).toList(),
//     };
//   }
// }
//
// // -----------------------------------------------------------------------------
//
// class TopicProgress {
//   final String topicId;
//   final bool isCompleted;
//
//   TopicProgress({
//     required this.topicId,
//     required this.isCompleted,
//   });
//
//   factory TopicProgress.fromMap(Map<String, dynamic> map) {
//     return TopicProgress(
//       topicId: map['topicId'] ?? '',
//       isCompleted: map['isCompleted'] ?? false,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'topicId': topicId,
//       'isCompleted': isCompleted,
//     };
//   }
// }

class StudyPlan {
  final String planId;
  final String stId;
  final String plan;

  StudyPlan({required this.planId, required this.stId, required this.plan});

  factory StudyPlan.fromMap(Map<String, dynamic> map) {
    return StudyPlan(
        planId: map['planId'] ?? '',
        stId: map['studentId'] ?? '',
        plan: map['plan'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {
      'planId': planId,
      'studentId': stId,
      'plan': plan
    };
  }
}
