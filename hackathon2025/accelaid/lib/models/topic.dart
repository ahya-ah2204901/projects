class Topic {
  final String compId;
  final String topicId;
  final String topic;

  Topic({
    required this.compId,
    required this.topicId,
    required this.topic,
  });

  factory Topic.fromMap(Map<String, dynamic> map, String compId) {
    return Topic(
      compId: compId,
      topicId: map['topicId'] ?? '',
      topic: map['topic'] ?? '',
    );
  }

  factory Topic.fromMapWithId(Map<String, dynamic> map) {
    return Topic(
      compId: map['compId'],
      topicId: map['topicId'] ?? '',
      topic: map['topic'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'compId': compId,
      'topicId': topicId,
      'topic': topic,
    };
  }

}
