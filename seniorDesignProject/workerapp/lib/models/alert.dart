class Alert {
  final String id;
  final String workerId;
  final String readingId;
  final DateTime time;
  final String severityLevel;
  final String description;
  final String status;

  Alert({
    required this.id,
    required this.workerId,
    required this.readingId,
    required this.time,
    required this.severityLevel,
    required this.description,
    this.status = 'PENDING',
  });

  factory Alert.fromMap(Map<String, dynamic> map) {
    return Alert(
      id: map['id'],
      //address: Address.fromMap(map['address']),
      workerId: map['workerId'],
      readingId: map['readingId'],
      time: DateTime.parse(map['time']),
      severityLevel: map['severityLevel'],
      description: map['description'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workerId': workerId,
      'readingId': readingId,
      'time': time.toString(),
      'severityLevel': severityLevel,
      'description': description,
      'status': status,
    };
  }
}
