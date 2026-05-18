import 'package:accelaid/models/topic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TopicRepo {
  final CollectionReference topicRef;

  TopicRepo({required this.topicRef});

  Future<List<Topic>> getTopicsByCompetency(String compId) async {
    try {
      final querySnapshot = await topicRef.where('compId', isEqualTo: compId).get();
      return querySnapshot.docs
          .map((doc) => Topic.fromMap(doc.data() as Map<String, dynamic>, compId))
          .toList();
    } catch (e) {
      print("Error fetching topics for compId $compId: $e");
      return [];
    }
  }

}
