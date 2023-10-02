import 'package:flutter/material.dart';

class FilterC {
  double radius = 5.0; // default to 5 kilometers
  double? latitude;
  double? longitude;
  String location = '';
  String hashtag = '';
  DateTime? startDate;
  TimeOfDay? startTime;

  FilterC({
    this.latitude,
    this.longitude,
    String? location,
    String? hashtag,
    this.startDate,
    this.startTime
  }) {
    if (location != null) {
      this.location = location;
    }
    if (hashtag != null) {
      this.hashtag = hashtag;
    }
  }

  List<Map<String, dynamic>> tags = [];

  void addTag(String key, dynamic value) {
    tags.add({key: value});
  }

  void removeTag(Map<String, dynamic> tag) {
    tags.remove(tag);
  }

  void reset() {
    tags.clear();
  }
}

