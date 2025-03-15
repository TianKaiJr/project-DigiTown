class DoctorLTA {
  final String doctorId;
  final Map<DateTime, bool> availability;

  DoctorLTA({required this.doctorId, required this.availability});

  factory DoctorLTA.fromFirestore(String doctorId, Map<String, dynamic> data) {
    Map<DateTime, bool> availability = {};
    data.forEach((key, value) {
      availability[DateTime.parse(key)] = value;
    });

    return DoctorLTA(
      doctorId: doctorId,
      availability: availability,
    );
  }

  Map<String, dynamic> toFirestore() {
    return availability
        .map((key, value) => MapEntry(key.toIso8601String(), value));
  }
}
