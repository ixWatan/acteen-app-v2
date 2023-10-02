// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:test/Posts%20Process/post.dart';

import '../user_interaction_service.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {

  void addEventToCalendar(Post post) {
    final DateTime? startDate = post.startDate;
    final TimeOfDay? startTime = post.startTime;
    final DateTime? endDate = post.endDate;
    final TimeOfDay? endTime = post.endTime;

    final DateTime? startDateTime = startDate != null && startTime != null
        ? DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute)
        : null;

    final DateTime? endDateTime = endDate != null && endTime != null
        ? DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute)
        : null;

    final Event event = Event(
      title: post.title,
      description: post.description,
      location: post.selectedLocation ?? '',
      startDate: startDateTime!,
      endDate: endDateTime!,
    );

    Add2Calendar.addEvent2Cal(event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
      ),
      body: Builder(
        builder: (BuildContext context) {
          // Call your function here
          updateUserInteractions(widget.post.selectedHashtags, 2);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              // Call the function as the screen initializes
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Here you can build your UI to display the post details just like you did in the card
                if (widget.post.title.isNotEmpty)
                  Text('Title: ${widget.post.title}', style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
                if (widget.post.description.isNotEmpty)
                  Text('Description: ${widget.post.description}'),
                if (widget.post.description.isNotEmpty)
                  Text('Description: ${widget.post.description}'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.post.selectedLocation != null)
                      Text('Location: ${widget.post.selectedLocation}'),
                    if (widget.post.startDate != null)
                      Text('Start Date: ${widget.post.startDate!
                          .toLocal()
                          .toString()
                          .split(' ')[0]}'),

                    if (widget.post.startTime != null)
                      Text('Start Time: ${widget.post.startTime!.format(
                          context)}'),
                    if (widget.post.endDate != null)
                      Text('End Date: ${widget.post.endDate!
                          .toLocal()
                          .toString()
                          .split(' ')[0]}'),
                    if (widget.post.endTime != null)
                      Text('End Time: ${widget.post.endTime!.format(context)}'),
                  ],
                ),
                if (widget.post.imagePath != null)
                  Image.network(
                    widget.post.imagePath!,
                    fit: BoxFit.cover,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width, // Full width of the screen
                    height: 400.0, // Fixed height
                  ),
                Wrap(
                  spacing: 8.0, // gap between adjacent chips
                  runSpacing: 4.0, // gap between lines
                  children: widget.post.selectedHashtags.map((hashtag) =>
                      Chip(label: Text(hashtag))).toList(),
                ),
                GestureDetector(
                    onTap: () => addEventToCalendar(widget.post),
                    child: const Text('Add To Calender'
                    )
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
