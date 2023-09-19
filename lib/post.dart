import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String userId;
  final String title;
  final String description;
  final List<String> selectedHashtags;
  final String? selectedLocation;
  final DateTime? startDate;
  final TimeOfDay? startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  String? imagePath;

  Post({
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
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      selectedHashtags: List<String>.from(json['hashtags'] ?? []),
      selectedLocation: json['location'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      startTime: json['startTime'] != null ? TimeOfDay.fromDateTime(DateTime.parse('1970-01-01 ${json['startTime']}')) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      endTime: json['endTime'] != null ? TimeOfDay.fromDateTime(DateTime.parse('1970-01-01 ${json['endTime']}')) : null,
      imagePath: json['imagePath'],
    );
  }

}





