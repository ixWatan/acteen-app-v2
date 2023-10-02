// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void updateUserInteractions(List<String> postHashtags, int incrementValue) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('activists').doc(user.uid).get();
  Map<String, int> userData = Map<String, int>.from((userDoc.data() as Map<String, dynamic>)['interests'] ?? {});

  for (String hashtag in postHashtags) {
    if (userData.containsKey(hashtag)) {
      userData[hashtag] = (userData[hashtag] ?? 0) + incrementValue;
    } else {
      userData[hashtag] = incrementValue;
    }
  }

  await FirebaseFirestore.instance.collection('activists').doc(user.uid).update({'interests': userData});
}
