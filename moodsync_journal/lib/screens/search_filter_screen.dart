import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/mood_entry.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({Key? key}) : super(key: key);

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  String searchText = '';
  String selectedMood = '';

  Stream<List<MoodEntry>> _getMoodEntriesStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('mood_entries')
        .where('uid', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MoodEntry.fromFirestore(doc))
        .where((entry) {
      final matchesSearch =
      entry.note.toLowerCase().contains(searchText.toLowerCase());
      final matchesMood =
          selectedMood.isEmpty || entry.mood == selectedMood;
      return matchesSearch && matchesMood;
    }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search & Filter')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Notes...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 8),
                _buildFilterChip('', 'All'),
                _buildFilterChip('😄', '😄'),
                _buildFilterChip('😊', '😊'),
                _buildFilterChip('😐', '😐'),
                _buildFilterChip('😞', '😞'),
                _buildFilterChip('😢', '😢'),
                _buildFilterChip('🥳', '🥳'),
                _buildFilterChip('😎', '😎'),
                const SizedBox(width: 8),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<MoodEntry>>(
              stream: _getMoodEntriesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final entries = snapshot.data ?? [];
                if (entries.isEmpty) {
                  return const Center(child: Text('No mood entries found.'));
                }
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return ListTile(
                      leading: Text(
                        entry.mood,
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(entry.note),
                      subtitle: Text(entry.timestamp.toString()),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String mood, String label) {
    final isSelected = selectedMood == mood;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            selectedMood = isSelected ? '' : mood;
          });
        },
      ),
    );
  }
}
