// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:test/post_detail_page.dart';
import 'filter_c.dart';
import 'post.dart';
import 'post_service.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final PostService postService = PostService();
  FilterC _currentFilter = FilterC();



  void _onFilterChanged(FilterC newFilter) {
    setState(() {
      _currentFilter = newFilter;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activist Feed'),
      ),
      body: Column(
        children: [
          FilterBar(
              onFilterChanged: _onFilterChanged,
              currentFilter: _currentFilter // passing the _currentFilter as currentFilter parameter
          ),
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: postService.fetchPosts(_currentFilter),
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
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailPage(post: post),
                            ),
                          );
                        },
                        child: PostCard(post: post),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterBar extends StatefulWidget {
  final ValueChanged<FilterC> onFilterChanged;
  final FilterC currentFilter;  // defining currentFilter
  const FilterBar({Key? key, required this.onFilterChanged, required this.currentFilter}) : super(key: key);

  @override
  _FilterBarState createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  String? selectedLocation;
  List<String>? selectedHashtags;
  DateTime? startDate;
  TimeOfDay? startTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: _showLocationFilterDialog,
              child: const Text('Location'),
            ),
            ElevatedButton(
              onPressed: _showHashtagsFilterDialog,
              child: const Text('Hashtags'),
            ),
            ElevatedButton(
              onPressed: _showTimeFilterDialog,
              child: const Text('Time'),
            ),
          ],
        ),
        Wrap(
          spacing: 6.0,
          children: widget.currentFilter.tags.map((tag) {
            return Chip(
              label: Text(tag.values.first.toString()),
              deleteIcon: const Icon(Icons.close),
              onDeleted: () {
                setState(() {
                  widget.currentFilter.removeTag(tag);
                });
                widget.onFilterChanged(widget.currentFilter);
              },
            );
          }).toList(),
        ),
      ],
    );

  }

  void _showLocationFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            children: [
              // Populate with your list of locations
              ListTile(
                title: const Text('Location 1'),
                onTap: () {
                  setState(() {
                    widget.currentFilter.location = 'Location 1';
                    widget.currentFilter.addTag('location', widget.currentFilter.location);
                  });
                  widget.onFilterChanged(widget.currentFilter); // Pass the updated currentFilter instance to the callback
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Location 2'),
                onTap: () {
                  setState(() {
                    setState(() {
                      widget.currentFilter.location = 'Location 2';
                      widget.currentFilter.addTag('location', widget.currentFilter.location);
                    });
                  });
                  widget.onFilterChanged(widget.currentFilter); // Pass the updated currentFilter instance to the callback
                  Navigator.pop(context);
                },

              ),
              // Add more locations as needed
            ],
          ),
        );
      },
    );
  }



  void _showHashtagsFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            children: [
              ListTile(
                title: const Text('Hashtag1'),
                onTap: () {
                  setState(() {
                    widget.currentFilter.hashtag = 'Hashtag1';
                    widget.currentFilter.addTag('hashtag', widget.currentFilter.hashtag);
                  });
                  widget.onFilterChanged(widget.currentFilter);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Hashtag2'),
                onTap: () {
                  setState(() {
                    widget.currentFilter.hashtag = 'Hashtag2';
                    widget.currentFilter.addTag('hashtag', widget.currentFilter.hashtag);
                  });
                  widget.onFilterChanged(widget.currentFilter);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }



  void _showTimeFilterDialog() {

    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ).then((date) {
      if (date != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((time) {
          if (time != null) {
            setState(() {
              widget.currentFilter.startDate = date;
              widget.currentFilter.startTime = time;

              // Adding tags for the selected date and time
              widget.currentFilter.addTag('startDate', date);
              widget.currentFilter.addTag('startTime', time.format(context));
            });
            widget.onFilterChanged(widget.currentFilter); // Pass the updated currentFilter instance to the callback
          }
        });
      }
    });
  }

}


class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
  });

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
            if (post.selectedLocation != null)
              Text('Location: ${post.selectedLocation}'),
            if (post.imagePath != null)
              Image.network(
                post.imagePath!,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width, // Full width of the screen
                height: 400.0, // Fixed height
              ),            Wrap(
              spacing: 6.0,
              children: post.selectedHashtags.map((hashtag) => Chip(label: Text(hashtag))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

