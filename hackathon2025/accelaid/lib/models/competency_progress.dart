import 'package:accelaid/models/topic_progress.dart';

class CompetencyProgress {
  final String stId;
  final String compId;
  late bool done;
  late List<TopicProgress> topicProgress;

  CompetencyProgress(
      {required this.stId,
      required this.compId,
      required this.done,
      required this.topicProgress});

  factory CompetencyProgress.fromMap(Map<String, dynamic> map) {
    return CompetencyProgress(
      stId: map['stId'],
      compId: map['compId'],
      done: map['done'] as bool,
      topicProgress: (map['topicProgress'] as List<dynamic>)
          .map((p) => TopicProgress.fromMap(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stId': stId,
      'compId': compId,
      'done': done,
      'topicProgress': topicProgress.map((p) => p.toMap()).toList(),
    };
  }

  void updateDoneStatus() {
    done = topicProgress.every((topic) => topic.done);
  }

}
