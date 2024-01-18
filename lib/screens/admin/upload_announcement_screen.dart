// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lost_found/models/announcement_model.dart';

class UploadAnnouncementScreen extends StatefulWidget {
  const UploadAnnouncementScreen({super.key});

  @override
  UploadAnnouncementScreenState createState() =>
      UploadAnnouncementScreenState();
}

class UploadAnnouncementScreenState extends State<UploadAnnouncementScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration:
                    const InputDecoration(labelText: 'Announcement Title'),
              ),
              TextField(
                controller: messageController,
                decoration:
                    const InputDecoration(labelText: 'Announcement Message'),
              ),
              // TextField(
              //   controller: itemStatusController,
              //   decoration: const InputDecoration(labelText: 'Item Status'),
              // ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Call the function to upload the item
                  uploadItem(
                    titleController.text,
                    messageController.text,
                  );
                },
                child: const Text('Upload Announcement'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> uploadItem(
    String name,
    String message,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('announcement').add(
          AnnouncementModel(
                  title: name, message: message, timestamp: DateTime.now())
              .toJson());

      // Show a success message or navigate to another screen.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Announcement uploaded successfully!'),
        ),
      );

      // Clear the text fields after successful upload.
      titleController.clear();
      messageController.clear();
    } catch (e) {
      // Handle any errors that occur during the upload.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading item: $e'),
        ),
      );
    }
  }
}
