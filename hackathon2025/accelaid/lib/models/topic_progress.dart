class TopicProgress {
  final String topicId;
  late bool done;

  TopicProgress({required this.topicId, required this.done});

  factory TopicProgress.fromMap(Map<String, dynamic> map) {
    return TopicProgress(
      topicId: map['topicId'] as String,
      done: map['done'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'topicId': topicId,
      'done': done,
    };
  }
}
