import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lost_found/constant.dart';
import 'package:lost_found/models/announcement_model.dart';
import 'package:lost_found/screens/jumma_details/upload_jumma_details.dart';
import 'package:timeago/timeago.dart' as timeago;

class JummaDetailsScreen extends StatefulWidget {
  const JummaDetailsScreen({super.key});

  @override
  State<JummaDetailsScreen> createState() => _JummaDetailsScreenState();
}

class _JummaDetailsScreenState extends State<JummaDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jumma Details',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          if (FirebaseAuth.instance.currentUser!.email == adminEmail)
            IconButton(
              icon: const Icon(Icons.upload),
              onPressed: () {
                // Handle search button click
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const UploadJummaDetailsScreen()));
              },
            ),
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('jumma_details')
              .orderBy('timestamp',
                  descending: true) // Sort by timestamp in descending order
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child:
                      CircularProgressIndicator()); // Loading indicator while data is being fetched.
            }

            if (snapshot.hasError || snapshot.data == null) {
              const Center(
                child: Text('Unexpected Error'),
              );
            }

            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                //     crossAxisCount: 2),
                itemBuilder: (context, index) {
                  var data = AnnouncementModel.fromJson(
                      snapshot.data!.docs[index].data());

                  return Card(
                    child: ListTile(
                      title: Text(
                        data.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.message,
                            style: const TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 20),
                          ),
                          Text(timeago.format(data.timestamp, locale: 'en'))
                        ],
                      ),
                      trailing: (FirebaseAuth.instance.currentUser!.email ==
                              adminEmail)
                          ? IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // Handle search button click
                                FirebaseFirestore.instance
                                    .collection('jumma_details')
                                    .doc(snapshot.data!.docs[index].id)
                                    .delete();
                              },
                            )
                          : null,
                    ),
                  );
                });
          }),
    );
  }
}
