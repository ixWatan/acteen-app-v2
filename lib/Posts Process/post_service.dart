// ignore_for_file: depend_on_referenced_packages, no_leading_underscores_for_local_identifiers
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'filter_c.dart';
import 'post.dart';

class PostService {

  Future<List<Post>> fetchPosts(FilterC filter) async {
    List<Post> posts = [];


    // Fetch all posts from the main_events collection
    QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance.collection('main_events').get();

    // Convert the documents to Post objects and add them to the posts list
    posts.addAll(eventsSnapshot.docs.map((eventDoc) => Post.fromJson(eventDoc.data() as Map<String, dynamic>)).toList());

    bool isTimeOfDayBefore(TimeOfDay timeToCheck, TimeOfDay referenceTime) {
      return timeToCheck.hour < referenceTime.hour ||
          (timeToCheck.hour == referenceTime.hour && timeToCheck.minute < referenceTime.minute);
    }

    double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
      const double p = 0.017453292519943295;
      final double a = 0.5 - cos((lat2 - lat1) * p)/2 +
          cos(lat1 * p) * cos(lat2 * p) *
              (1 - cos((lon2 - lon1) * p))/2;
      return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
    }

    for (var tag in filter.tags) {
      String key = tag.keys.first;
      dynamic value = tag.values.first;

      if (key == 'location') {
        posts = posts.where((post) {
          if (filter.latitude != null && filter.longitude != null && post.latitude != null && post.longitude != null) {
            final double distance = calculateDistance(
                filter.latitude!,
                filter.longitude!,
                post.latitude!,
                post.longitude!
            );
            // Return true if the distance is within the specified radius, else false
            return distance <= filter.radius;
          }
          return false; // Exclude the post if either filter or post doesn't have latitude/longitude
        }).toList();
      }




      if (key == 'hashtag') {
        posts = posts.where((post) => post.selectedHashtags.contains(value)).toList();
      }


      if (key == 'startDate') {
        DateTime filterDate = value; // Assuming value is a DateTime object
        posts = posts.where((post) =>
        post.startDate != null &&
            (
                DateTime(post.startDate!.year, post.startDate!.month, post.startDate!.day).isBefore(
                    DateTime(filterDate.year, filterDate.month, filterDate.day)
                ) ||
                    DateTime(post.startDate!.year, post.startDate!.month, post.startDate!.day).isAtSameMomentAs(
                        DateTime(filterDate.year, filterDate.month, filterDate.day)
                    )
            )
        ).toList();
      }



      if (key == 'startTime') {
        TimeOfDay filterTime = value;
        posts = posts.where((post) => post.startTime != null && (isTimeOfDayBefore(post.startTime!, filterTime) || (post.startTime!.hour == filterTime.hour && post.startTime!.minute == filterTime.minute))).toList();
      }


    }


    // Sort by points and then by closeness to the current date
    posts.sort((a, b) {
      int compare = b.points.compareTo(a.points); // Primary sorting by points

      if (compare == 0 && a.startDate != null && b.startDate != null) {
        // Secondary sorting by closeness to the current date when points are equal
        return a.startDate!.difference(DateTime.now()).compareTo(b.startDate!.difference(DateTime.now()));
      }

      return compare;
    });

    return posts;
  }


}


