// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_page_activists.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  Map<String, int> hashtagCounts = {
    'Hashtag1': 0,
    'Hashtag2': 0,
    'Hashtag3': 0,
    'Hashtag4': 0,
    'Hashtag5': 0,
    // ... Initialize all hashtags with 0
  };

  void onHashtagSelected(String hashtag, bool isSelected) {
    setState(() {
      hashtagCounts[hashtag] = isSelected ? 1 : 0;
    });
  }


  void _submitInterests() async {
    final user = FirebaseAuth.instance.currentUser; // get current logged in user

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('activists')
            .doc(user.uid)
            .update({
          'interests': hashtagCounts,
        });

        // Navigate to HomePage after saving interests
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePageActivists()));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error updating interests: $error"),
            backgroundColor: Colors.red, // Optional: you can style the SnackBar
            duration: const Duration(seconds: 3), // Optional: adjust the display duration
          ),
        );
      }
    }
  }









  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Interests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: hashtagCounts.length,
          itemBuilder: (context, index) {
            String hashtag = hashtagCounts.keys.elementAt(index);
            return CheckboxListTile(
              title: Text(hashtag),
              value: hashtagCounts[hashtag] == 1,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    hashtagCounts[hashtag] = 1;
                  } else {
                    hashtagCounts[hashtag] = 0;
                  }
                });
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitInterests,
        child: const Icon(Icons.check),
      ),
    );
  }

}
