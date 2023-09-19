import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'filter_c.dart';
import 'post.dart';


class PostService {
  Future<List<Post>> fetchPosts(FilterC filter) async {
    List<Post> posts = [];


    // Step 1: Fetch all organizations
    QuerySnapshot organizationsSnapshot = await FirebaseFirestore.instance.collection('organizations').get();

    // Step 2: For each organization, fetch all events and add them to the posts list
    for (QueryDocumentSnapshot organizationDocument in organizationsSnapshot.docs) {
      QuerySnapshot eventsSnapshot = await organizationDocument.reference.collection('events').get();
      posts.addAll(eventsSnapshot.docs.map((eventDoc) => Post.fromJson(eventDoc.data() as Map<String, dynamic>)).toList());
    }

    bool isTimeOfDayBefore(TimeOfDay timeToCheck, TimeOfDay referenceTime) {
      return timeToCheck.hour < referenceTime.hour ||
          (timeToCheck.hour == referenceTime.hour && timeToCheck.minute < referenceTime.minute);
    }


/*    // Step 3: Apply filters
    if (filter.location != null && filter.location!.isNotEmpty) {
      posts = posts.where((post) => post.selectedLocation == filter.location).toList();
    }

    if (filter.hashtags != null && filter.hashtags!.isNotEmpty) {
      posts = posts.where((post) => post.selectedHashtags.any((tag) => filter.hashtags!.contains(tag))).toList();
    }

    if (filter.startDate != null && filter.startTime != null) {
      final selectedDateTime = DateTime(
          filter.startDate!.year,
          filter.startDate!.month,
          filter.startDate!.day,
          filter.startTime!.hour,
          filter.startTime!.minute,
          0, // Setting seconds to 0
          0  // Setting milliseconds to 0
      );
      posts = posts.where((post) =>
      post.startDate != null &&
          post.startTime != null &&
          !DateTime(
              post.startDate!.year,
              post.startDate!.month,
              post.startDate!.day,
              post.startTime!.hour,
              post.startTime!.minute,
              0, // Setting seconds to 0
              0  // Setting milliseconds to 0
          ).isBefore(selectedDateTime) // Using !isBefore to include posts at the exact selected time
      ).toList();
    }*/

    for (var tag in filter.tags) {
      String key = tag.keys.first;
      dynamic value = tag.values.first;

      if (key == 'location') {
        posts = posts.where((post) => post.selectedLocation == value).toList();
      }

      if (key == 'hashtag') {
        posts = posts.where((post) => post.selectedHashtags.contains(value)).toList();
      }


      if (key == 'startDate') {
        DateTime filterDate = value; // Assuming value is a DateTime object
        posts = posts.where((post) =>
        post.startDate != null &&
            DateTime(post.startDate!.year, post.startDate!.month, post.startDate!.day).isBefore(
                DateTime(filterDate.year, filterDate.month, filterDate.day)
            )
        ).toList();
      }


     /* if (key == 'startDate') {
        DateTime filterDate = value; // Assuming value is a DateTime object
        posts = posts.where((post) =>
        post.startDate != null &&
            post.startDate!.year == filterDate.year &&
            post.startDate!.month == filterDate.month &&
            post.startDate!.day == filterDate.day
        ).toList();
      }*/




      if (key == 'startTime') {
        TimeOfDay filterTime = value;
        posts = posts.where((post) => post.startTime != null && (isTimeOfDayBefore(post.startTime!, filterTime) || (post.startTime!.hour == filterTime.hour && post.startTime!.minute == filterTime.minute))).toList();
      }


    }



    return posts;
  }


}


