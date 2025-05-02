import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/mood_entry.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  List<MoodEntry> _allEntries = [];

  @override
  void initState() {
    super.initState();
    _fetchMoodEntries();
  }

  Future<void> _fetchMoodEntries() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('mood_entries')
        .where('uid', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .get();

    final entries =
    snapshot.docs.map((doc) => MoodEntry.fromFirestore(doc)).toList();

    setState(() {
      _allEntries = entries;
    });
  }

  List<MoodEntry> _getFilteredEntries() {
    if (_rangeStart != null && _rangeEnd != null) {
      return _allEntries.where((entry) {
        final ts = entry.timestamp;
        return ts.isAfter(_rangeStart!.subtract(const Duration(days: 1))) &&
            ts.isBefore(_rangeEnd!.add(const Duration(days: 1)));
      }).toList();
    } else if (_selectedDay != null) {
      return _allEntries.where((entry) {
        return entry.timestamp.year == _selectedDay!.year &&
            entry.timestamp.month == _selectedDay!.month &&
            entry.timestamp.day == _selectedDay!.day;
      }).toList();
    } else {
      return [];
    }
  }

  void _showMoodDetails(MoodEntry entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Mood: ${entry.mood}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(entry.note),
            const SizedBox(height: 10),
            if (entry.imageUrl != null && entry.imageUrl!.isNotEmpty)
              Image.network(entry.imageUrl!, height: 150),
            const SizedBox(height: 10),
            Text(
              'Date: ${entry.timestamp.toLocal().toString().split(" ")[0]}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleEntries = _getFilteredEntries();

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar View')),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: CalendarFormat.month, // Fixed format
            availableCalendarFormats: const {
              CalendarFormat.month: '',
            }, // 👈 disables the toggle button
            rangeSelectionMode: _rangeSelectionMode,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onFormatChanged: (_) {}, // Disable format change
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _rangeStart = null;
                _rangeEnd = null;
                _rangeSelectionMode = RangeSelectionMode.toggledOff;
              });
            },
            onRangeSelected: (start, end, focusedDay) {
              setState(() {
                _rangeStart = start;
                _rangeEnd = end;
                _focusedDay = focusedDay;
                _selectedDay = null;
                _rangeSelectionMode = RangeSelectionMode.toggledOn;
              });
            },
          ),

          const SizedBox(height: 10),
          Expanded(
            child: visibleEntries.isEmpty
                ? const Center(child: Text('No mood entries for selection.'))
                : ListView.builder(
              itemCount: visibleEntries.length,
              itemBuilder: (context, index) {
                final entry = visibleEntries[index];
                return ListTile(
                  leading: Text(entry.mood,
                      style: const TextStyle(fontSize: 24)),
                  title: Text(entry.note),
                  subtitle: Text(entry.timestamp.toString()),
                  onTap: () => _showMoodDetails(entry),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
