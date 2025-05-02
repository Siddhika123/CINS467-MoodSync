import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final TextEditingController _noteController = TextEditingController();
  File? _imageFile;
  String? _selectedEmoji;
  bool _isLoading = false;

  final List<String> _emojis = [
    '😄', '😢', '😡', '😱', '🥳', '😭', '😴', '🤔', '😎', '😍', '🤯', '😐'
  ];

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    final fileName = const Uuid().v4();
    final ref = FirebaseStorage.instance
        .ref()
        .child('mood_images')
        .child('$fileName.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _saveMoodEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save entries')),
      );
      return;
    }

    if (_selectedEmoji == null || _noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select mood and write journal note')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      await FirebaseFirestore.instance.collection('mood_entries').add({
        'uid': user?.uid,
        'timestamp': Timestamp.now(),
        'mood': _selectedEmoji,
        'note': _noteController.text,
        'photo_url': imageUrl ?? '',
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error saving mood: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save mood entry')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Mood Entry')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Select Your Mood',
                style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 10,
              children: _emojis.map((emoji) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: _selectedEmoji == emoji
                        ? Colors.blue
                        : Colors.grey[200],
                    child: Text(emoji,
                        style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Journal Note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _imageFile != null
                ? Image.file(_imageFile!, height: 150)
                : const Text('No photo selected'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMoodEntry,
              child: const Text('Save Mood Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
