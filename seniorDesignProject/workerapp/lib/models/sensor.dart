class Sensor {
  final String id;
  final String type;
  final String workerId;

  Sensor({required this.id, required this.type, required this.workerId});

  factory Sensor.fromMap(Map<String, dynamic> map) {
    return Sensor(id: map['id'], type: map['type'], workerId: map['workerId']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'type': type, 'workerId': workerId};
  }
}

class SensorData {
  final double temperature;
  final double humidity;
  final double bodyTemp;
  final double heartRate;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.bodyTemp,
    required this.heartRate,
  });

  factory SensorData.fromMap(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      bodyTemp: (json['bodyTemp'] ?? 0).toDouble(),
      heartRate: (json['heartRate'] ?? 0).toInt() + 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'bodyTemp': bodyTemp,
      'heartRate': heartRate,
    };
  }
}

String breathingLabelFromCode(num value) {
  switch (value.toInt()) {
    case 0:
      return "CALIBRATING";
    case 1:
      return "NORMAL";
    case 2:
      return "HIGH BREATHING";
    case 3:
      return "LOW BREATHING";
    case 4:
      return "IRREGULAR BREATHING";
    case 5:
      return "NO BREATHING";
    case 6:
      return "BAD FIT / MOTION";
    default:
      return "UNKNOWN";
  }
}
