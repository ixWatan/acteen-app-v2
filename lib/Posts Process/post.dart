import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post {
  double? latitude;
  double? longitude;
  String userId;
  String title;
  String description;
  List<String> selectedHashtags;
  String? selectedLocation;
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;
  String? imagePath;
  int points;
  int likesCount;
  int attendeesCount;
  String postId;
  // Reference to the Firestore collection
  final CollectionReference postsRef = FirebaseFirestore.instance.collection('main_events');
  List<String> likedByUserIds = [];
  List<String> attendedByUserIds = [];

  Post({
    required this.postId,
    this.latitude,
    this.longitude,
    required this.userId,
    required this.title,
    required this.selectedHashtags,
    required this.description,
    this.startDate,
    this.selectedLocation,
    this.startTime,
    this.endDate,
    this.endTime,
    this.imagePath,
    required this.points,
    required this.likesCount,
    required this.attendeesCount,
    List<String>? likedByUserIds,
    List<String>? attendedByUserIds,
  }){
    this.likedByUserIds = likedByUserIds ?? [];
    this.attendedByUserIds = attendedByUserIds ?? [];
  }

  factory Post.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> docData = doc.data()!;
    return Post(
      postId: doc.id,
      userId: docData['userId'] ?? '',
      title: docData['title'] ?? '',
      description: docData['description'] ?? '',
      selectedHashtags: List<String>.from(docData['selectedHashtags'] ?? []),
      likesCount: docData['likesCount'] ?? 0,
      attendeesCount: docData['attendeesCount'] ?? 0,
      points: docData['points'] ?? 0,
      latitude: docData['latitude'] as double?,
      longitude: docData['longitude'] as double?,
      selectedLocation: docData['selectedLocation'],
      imagePath: docData['imagePath'],
      startDate: docData['startDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(docData['startDate'].millisecondsSinceEpoch)
          : null,
      endDate: docData['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(docData['endDate'].millisecondsSinceEpoch)
          : null,
      startTime: docData['startTime'] != null
          ? TimeOfDay(hour: int.parse((docData['startTime'] ?? '').split(':')[0]),
          minute: int.parse((docData['startTime'] ?? '').split(':')[1]))
          : null,
      endTime: docData['endTime'] != null
          ? TimeOfDay(hour: int.parse((docData['endTime'] ?? '').split(':')[0]),
          minute: int.parse((docData['endTime'] ?? '').split(':')[1]))
          : null,
    );
  }



  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'] ?? '', // Make sure postId is properly set in your Firestore documents
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      selectedHashtags: List<String>.from(json['hashtags'] ?? []),
      selectedLocation: json['location'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      startTime: json['startTime'] != null ? TimeOfDay.fromDateTime(DateTime.parse('1970-01-01 ${json['startTime']}')) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      endTime: json['endTime'] != null ? TimeOfDay.fromDateTime(DateTime.parse('1970-01-01 ${json['endTime']}')) : null,
      imagePath: json['imagePath'],
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      points: json['Points'] ?? 0,
      likesCount: json['likesCount'] ?? 0,
      attendeesCount: json['attendeesCount'] ?? 0,
    );
  }

  Future<void> toggleLikePost(String currentUserId) async {
    if (likedByUserIds.contains(currentUserId)) {
      likedByUserIds.remove(currentUserId);
      likesCount -= 1;
    } else {
      likedByUserIds.add(currentUserId);
      likesCount += 1;
    }
    await postsRef.doc(postId).update({
      'likesCount': likesCount,
      'likedByUserIds': likedByUserIds,
    });
  }

  Future<void> toggleAttendPost(String currentUserId) async {
    if (attendedByUserIds.contains(currentUserId)) {
      attendedByUserIds.remove(currentUserId);
      attendeesCount -= 1;
    } else {
      attendedByUserIds.add(currentUserId);
      attendeesCount += 1;
    }
    await postsRef.doc(postId).update({
      'attendeesCount': attendeesCount,
      'attendedByUserIds': attendedByUserIds,
    });
  }

}





