import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntry {
  final String? id;
  final String mood;
  final String note;
  final DateTime timestamp;
  final String? imageUrl;
  final String uid; // 🆕 Add this

  MoodEntry({
    this.id,
    required this.mood,
    required this.note,
    required this.timestamp,
    this.imageUrl,
    required this.uid, // 🆕 Required
  });

  Map<String, dynamic> toMap() {
    return {
      'mood': mood,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
      'uid': uid, // 🆕 Save to Firestore
    };
  }

  factory MoodEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MoodEntry(
      id: doc.id,
      mood: data['mood'] ?? '',
      note: data['note'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      uid: data['uid'] ?? '', // 🆕
    );
  }
}
