class DoctorAttendance {
  final String id;
  final String name;
  final String designation;
  final String status;
  final String timestamp;

  DoctorAttendance({
    required this.id,
    required this.name,
    required this.designation,
    required this.status,
    required this.timestamp,
  });

  factory DoctorAttendance.fromMap(String id, Map<String, dynamic> data) {
    return DoctorAttendance(
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
