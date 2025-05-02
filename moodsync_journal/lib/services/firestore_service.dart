import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_entry.dart';

class FirestoreService {
  static Future<void> addMoodEntry(MoodEntry entry) async {
    await FirebaseFirestore.instance
        .collection('mood_entries')
        .add(entry.toMap());
  }

  static Stream<List<MoodEntry>> getMoodEntries({required String uid}) {
    return FirebaseFirestore.instance
        .collection('mood_entries')
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => MoodEntry.fromFirestore(doc)).toList());
  }


  static Future<void> deleteMoodEntry(String id) async {
    await FirebaseFirestore.instance.collection('mood_entries').doc(id).delete();
  }
}
