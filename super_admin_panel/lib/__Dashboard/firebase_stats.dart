import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, int>> fetchMonthlyRegistrations() async {
  // Fetch all user documents
  final usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();

  // This will hold month-string => count
  final Map<String, int> monthlyCounts = {};

  for (var doc in usersSnapshot.docs) {
    // Convert Timestamp to DateTime
    final data = doc.data();
    final Timestamp timestamp = data['createdAt'] ?? Timestamp.now();
    final DateTime createdAt = timestamp.toDate();

    // Create a "YYYY-MM" key
    final String yearMonth =
        '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';

    // Increment the count
    monthlyCounts[yearMonth] = (monthlyCounts[yearMonth] ?? 0) + 1;
  }

  return monthlyCounts;
}
