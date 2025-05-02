import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_entry.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    await AuthService.logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  void _goToAddEntry(BuildContext context) {
    Navigator.pushNamed(context, '/add-entry');
  }

  void _deleteEntry(String id) {
    FirestoreService.deleteMoodEntry(id);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoodSync Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: Text('User not logged in'))
          : StreamBuilder<List<MoodEntry>>(
        stream: FirestoreService.getMoodEntries(uid: currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No entries yet.'));
          }

          final entries = snapshot.data!;

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Text(entry.mood,
                      style: const TextStyle(fontSize: 24)),
                  title: Text(entry.note),
                  subtitle: Text(entry.timestamp.toString()),
                  trailing: IconButton(
                    icon:
                    const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteEntry(entry.id!),
                  ),
                  onTap: () {
                    // TODO: Navigate to detail view
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped on ${entry.note}')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToAddEntry(context),
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('MoodSync Menu', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            ListTile(
              title: const Text('Add Entry'),
              onTap: () => Navigator.pushNamed(context, '/add-entry'),
            ),
            ListTile(
              title: const Text('Calendar View'),
              onTap: () => Navigator.pushNamed(context, '/calendar'),
            ),
            ListTile(
              title: const Text('Visualization'),
              onTap: () => Navigator.pushNamed(context, '/visualization'),
            ),
            ListTile(
              title: const Text('Search & Filter'),
              onTap: () => Navigator.pushNamed(context, '/search'),
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            const Divider(),
            ListTile(
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
