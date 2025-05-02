import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:pie_chart/pie_chart.dart' as pc;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_entry.dart';

class VisualizationScreen extends StatefulWidget {
  const VisualizationScreen({super.key});

  @override
  State<VisualizationScreen> createState() => _VisualizationScreenState();
}

class _VisualizationScreenState extends State<VisualizationScreen> {
  List<fl.FlSpot> moodTimeline = [];
  Map<String, double> moodPieData = {};

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  Future<void> _loadMoodData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('mood_entries')
        .where('uid', isEqualTo: user.uid)
        .orderBy('timestamp')
        .get();

    final List<fl.FlSpot> timeline = [];
    final Map<String, int> moodCount = {};

    int index = 0;
    for (var doc in snapshot.docs) {
      final entry = MoodEntry.fromFirestore(doc);
      final score = _mapMoodToScore(entry.mood);
      timeline.add(fl.FlSpot(index.toDouble(), score));
      moodCount[entry.mood] = (moodCount[entry.mood] ?? 0) + 1;
      index++;
    }

    final Map<String, double> pieData = {
      for (var entry in moodCount.entries) entry.key: entry.value.toDouble()
    };

    setState(() {
      moodTimeline = timeline;
      moodPieData = pieData;
    });
  }

  double _mapMoodToScore(String mood) {
    switch (mood) {
      case '😄':
        return 5.0;
      case '😊':
        return 4.0;
      case '😐':
        return 3.0;
      case '😞':
        return 2.0;
      case '😢':
        return 1.0;
      default:
        return 3.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Visualization')),
      body: moodTimeline.isEmpty && moodPieData.isEmpty
          ? const Center(child: Text('No mood data yet.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Mood Trends Over Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: fl.LineChart(
                fl.LineChartData(
                  titlesData: fl.FlTitlesData(
                    leftTitles: fl.AxisTitles(
                      sideTitles: fl.SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, _) {
                          switch (value.toInt()) {
                            case 5:
                              return const Text('Happy');
                            case 4:
                              return const Text('Good');
                            case 3:
                              return const Text('Okay');
                            case 2:
                              return const Text('Sad');
                            case 1:
                              return const Text('Very Sad');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    bottomTitles: fl.AxisTitles(
                      sideTitles: fl.SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: fl.FlGridData(show: true),
                  borderData: fl.FlBorderData(show: true),
                  lineBarsData: [
                    fl.LineChartBarData(
                      spots: moodTimeline,
                      isCurved: true,
                      barWidth: 4,
                      belowBarData: fl.BarAreaData(show: false),
                      dotData: fl.FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Mood Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            pc.PieChart(
              dataMap: moodPieData,
              chartRadius: MediaQuery.of(context).size.width / 2.2,
              chartType: pc.ChartType.disc,
              legendOptions: const pc.LegendOptions(legendPosition: pc.LegendPosition.right),
              chartValuesOptions: const pc.ChartValuesOptions(showChartValuesInPercentage: true),
            ),
          ],
        ),
      ),
    );
  }
}
