// ignore_for_file: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
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

  late Post post;

  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  final User? user = FirebaseAuth.instance.currentUser;

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


  Future<void> handleLikeButtonPress(String currentUserId) async {
    await post.toggleLikePost(currentUserId);
    setState(() {});
  }

  Future<void> handleAttendButtonPress(String currentUserId) async {
    await post.toggleAttendPost(currentUserId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = user?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
      ),
      body: Builder(
        builder: (BuildContext context) {
          // Call your function here
          updateUserInteractions(post.selectedHashtags, 2);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Here you can build your UI to display the post details just like you did in the card
                  if (post.title.isNotEmpty)
                    Text('Title: ${post.title}', style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                  if (post.description.isNotEmpty)
                    Text('Description: ${post.description}'),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.selectedLocation != null)
                        Text('Location: ${post.selectedLocation}'),
                      if (post.startDate != null)
                        Text('Start Date: ${post.startDate!
                            .toLocal()
                            .toString()
                            .split(' ')[0]}'),

                      if (post.startTime != null)
                        Text('Start Time: ${post.startTime!.format(
                            context)}'),
                      if (post.endDate != null)
                        Text('End Date: ${post.endDate!
                            .toLocal()
                            .toString()
                            .split(' ')[0]}'),
                      if (post.endTime != null)
                        Text('End Time: ${post.endTime!.format(context)}'),
                    ],
                  ),
                  if (post.imagePath != null)
                    Image.network(
                      post.imagePath!,
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
                    children: post.selectedHashtags.map((hashtag) =>
                        Chip(label: Text(hashtag))).toList(),
                  ),
                  GestureDetector(
                      onTap: () => addEventToCalendar(post),
                      child: const Text('Add To Calender'
                      )
                  ),
                  IconButton(
                    icon: Icon(
                      post.likedByUserIds.contains(currentUserId)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: post.likedByUserIds.contains(currentUserId) ? Colors.red: null,
                    ),
                    onPressed: () => handleLikeButtonPress(currentUserId),
                  ),
                  Text("${post.likesCount}"),
                  IconButton(
                    icon: Icon(
                      post.attendedByUserIds.contains(currentUserId)
                          ? Icons.event_available
                          : Icons.event,
                    ),
                    onPressed: () => handleAttendButtonPress(currentUserId),
                  ),
                  Text("${post.attendeesCount}"),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
