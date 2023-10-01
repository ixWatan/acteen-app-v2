// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:test/post.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});


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
        iosParams: const IOSParams(reminder: Duration(minutes: 30)),
        androidParams: const AndroidParams(emailInvites: [])
    );

    Add2Calendar.addEvent2Cal(event).then((value) {

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Here you can build your UI to display the post details just like you did in the card
            if (post.title.isNotEmpty)
              Text('Title: ${post.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (post.description.isNotEmpty)
              Text('Description: ${post.description}'),
            if (post.description.isNotEmpty)
              Text('Description: ${post.description}'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.selectedLocation != null)
                  Text('Location: ${post.selectedLocation}'),
                if (post.startDate != null)
                  Text('Start Date: ${post.startDate!.toLocal().toString().split(' ')[0]}'),
                if (post.startTime != null)
                  Text('Start Time: ${post.startTime!.format(context)}'),
                if (post.endDate != null)
                  Text('End Date: ${post.endDate!.toLocal().toString().split(' ')[0]}'),
                if (post.endTime != null)
                  Text('End Time: ${post.endTime!.format(context)}'),
              ],
            ),
            if (post.imagePath != null)
              Image.network(
                post.imagePath!,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width, // Full width of the screen
                height: 400.0, // Fixed height
              ),
            GestureDetector(
                onTap: () => addEventToCalendar(post),
                child: const Text('Add To Calender'
                )
            ),

          ],
        ),
      ),
    );
  }
}
