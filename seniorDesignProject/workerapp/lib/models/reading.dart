class Reading {
  final String id;
  final DateTime time;
  final num value;
  final String sensorId;

  Reading({
    required this.id,
    required this.time,
    required this.value,
    required this.sensorId,
  });

  factory Reading.fromMap(Map<String, dynamic> map) {
    return Reading(
      id: map['id'],
      time: DateTime.parse(map['time']),
      value: map['value'],
      sensorId: map['sensorId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time.toString(),
      'value': value,
      'sensorId': sensorId,
    };
  }
}
