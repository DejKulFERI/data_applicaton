class DeviceData {
  List<double> accelerometerX = [];
  List<double> accelerometerY = [];
  List<double> accelerometerZ = [];
  List<double> gyroscopeX = [];
  List<double> gyroscopeY = [];
  List<double> gyroscopeZ = [];
  double latitude;
  double longitude;
  DateTime timestamp;
  String user;
  double rating;

  DeviceData({
    required this.accelerometerX,
    required this.accelerometerY,
    required this.accelerometerZ,
    required this.gyroscopeX,
    required this.gyroscopeY,
    required this.gyroscopeZ,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.user,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'accelerometerX': accelerometerX,
      'accelerometerY': accelerometerY,
      'accelerometerZ': accelerometerZ,
      'gyroscopeX': gyroscopeX,
      'gyroscopeY': gyroscopeY,
      'gyroscopeZ': gyroscopeZ,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'user': user,
      'rating': rating,
    };
  }

  @override
  String toString() {
    return 'DeviceData{\n'
        '  accelerometerX: $accelerometerX,\n'
        '  accelerometerY: $accelerometerY,\n'
        '  accelerometerZ: $accelerometerZ,\n'
        '  gyroscopeX: $gyroscopeX,\n'
        '  gyroscopeY: $gyroscopeY,\n'
        '  gyroscopeZ: $gyroscopeZ,\n'
        '  latitude: $latitude,\n'
        '  longitude: $longitude,\n'
        '  timestamp: $timestamp,\n'
        '  user: $user,\n'
        '  rating: $rating\n'
        '}';
  }
}
