class DoctorAttendence {
  final String id;
  final String name;
  final String designation;
  final String status;
  final String timestamp;

  DoctorAttendence({
    required this.id,
    required this.name,
    required this.designation,
    required this.status,
    required this.timestamp,
  });

  factory DoctorAttendence.fromMap(Map<String, dynamic> data, String id) {
    return DoctorAttendence(
      id: id,
      name: data['name'] ?? '',
      designation: data['designation'] ?? '',
      status: data['status'] ?? 'Available',
      timestamp: data['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'designation': designation,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
