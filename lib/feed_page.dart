// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'post.dart';
import 'post_service.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class FeedPage extends StatelessWidget {
  final PostService postService = PostService();

  FeedPage({super.key});




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activist Feed'),
      ),
      body: FutureBuilder<List<Post>>(
        future: postService.fetchPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts available.'));
          } else {
            final List<Post> posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(post: post);
              },
            );
          }
        },
      ),

    );
  }

}

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
  });

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

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.title.isNotEmpty)
              Text('Title: ${post.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (post.description.isNotEmpty)
              Text('Description: ${post.description}'),
            GestureDetector(
              onTap: () => addEventToCalendar(post),
              child: Column(
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
            ),
            if (post.imagePath != null)
              Image.network(post.imagePath!, fit: BoxFit.cover),
            Wrap(
              spacing: 6.0,
              children: post.selectedHashtags.map((hashtag) => Chip(label: Text(hashtag))).toList(),
            ),
          ],
        ),
      ),
    );
  }



}

