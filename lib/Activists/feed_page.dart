// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously, must_be_immutable
import 'package:flutter/material.dart';
import 'package:test/Posts%20Process/post_detail_page.dart';
import '../Posts Process/filter_c.dart';
import '../Posts Process/post.dart';
import '../Posts Process/post_service.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> getUserId() async {
  return FirebaseAuth.instance.currentUser?.uid;
}

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();

}



class _FeedPageState extends State<FeedPage> {

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    //call the update_posts_points function
    User? currentUser = FirebaseAuth.instance.currentUser; // Get the current user

    if (currentUser != null) { // Check if a user is currently signed in
      String userId = currentUser.uid; // Get the user ID
      await callCloudFunction(userId, context);// Call the cloud function with the user ID
    } else {
      // Handle the case where no user is signed in if necessary
    }
  }



  final PostService postService = PostService();
  FilterC _currentFilter = FilterC();



  void _onFilterChanged(FilterC newFilter) {
    setState(() {
      _currentFilter = newFilter;
    });

  }

  Future<void> callCloudFunction(String userId, BuildContext context) async {
    const functionUrl = "https://us-central1-acteen--flutter-app.cloudfunctions.net/update_post_points";

    final response = await http.post(
      Uri.parse(functionUrl),
      headers: {"Content-Type": "application/json"}, // Set the Content-Type to application/json
      body: jsonEncode({'userId': userId}), // Convert the body to a JSON string
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.statusCode == 200 ? 'Function called successfully.' : 'Failed to call the function.',
        ),
        duration: const Duration(seconds: 3), // Adjust the duration as needed
      ),
    );

    if (response.statusCode == 200) {
      // You might want to do something with the response here
    } else {
      // You might want to handle the error here
    }
  }


  Future<void> _handleRefresh() async {
    //call the update_posts_points function
    User? currentUser = FirebaseAuth.instance.currentUser; // Get the current user

    if (currentUser != null) { // Check if a user is currently signed in
      String userId = currentUser.uid; // Get the user ID
      await callCloudFunction(userId, context);// Call the cloud function with the user ID
    } else {
      // Handle the case where no user is signed in if necessary
    }

    // Trigger a state rebuild to refresh the posts
    setState(() {});

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
                  return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: ListView.builder(
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
                    ),
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
  FilterC currentFilter;  // Removed 'final'

  FilterBar({Key? key, required this.onFilterChanged, required this.currentFilter}) : super(key: key);

  @override
  _FilterBarState createState() => _FilterBarState();
}


class _FilterBarState extends State<FilterBar> {
  double? latitude;
  double? longitude;
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
            ElevatedButton(
              onPressed: _showDateFilterDialog,
              child: const Text('Date'),
            ),
          ],
        ),
        Wrap(
          spacing: 6.0,
          children: widget.currentFilter.tags.map((tag) {
            String label;
            dynamic value = tag.values.first;
            if (value is DateTime) {
              label = value.toLocal().toIso8601String().split(
                  "T")[0]; // Keep only the date part
            } else if (value is TimeOfDay) {
              label = value.format(context); // Format TimeOfDay
            } else {
              label = value.toString();
            }

            return Chip(
              label: Text(label),
              deleteIcon: const Icon(Icons.close),
              onDeleted: () {
                setState(() {
                  widget.currentFilter.removeTag(tag);
                });
                widget.onFilterChanged(widget.currentFilter);
              },
            );
          }).toList(),
        )

      ],
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
              ListTile(
                title: const Text('Hashtag3'),
                onTap: () {
                  setState(() {
                    widget.currentFilter.hashtag = 'Hashtag3';
                    widget.currentFilter.addTag('hashtag', widget.currentFilter.hashtag);
                  });
                  widget.onFilterChanged(widget.currentFilter);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Hashtag4'),
                onTap: () {
                  setState(() {
                    widget.currentFilter.hashtag = 'Hashtag4';
                    widget.currentFilter.addTag('hashtag', widget.currentFilter.hashtag);
                  });
                  widget.onFilterChanged(widget.currentFilter);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Hashtag5'),
                onTap: () {
                  setState(() {
                    widget.currentFilter.hashtag = 'Hashtag5';
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


  void _showDateFilterDialog() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ).then((date) {
      if (date != null) {
        setState(() {
          widget.currentFilter.startDate = date;

          // Adding tags for the selected date
          widget.currentFilter.addTag('startDate', date);

        });
        widget.onFilterChanged(widget.currentFilter); // Pass the updated currentFilter instance to the callback
      }
    });
  }

  void _showTimeFilterDialog() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((time) {
      if (time != null) {
        setState(() {
          widget.currentFilter.startTime = time;

          // Adding tags for the selected time
          widget.currentFilter.addTag('startTime', time); // <-- store TimeOfDay object
        });
        widget.onFilterChanged(widget.currentFilter); // Pass the updated currentFilter instance to the callback
      }
    });
  }


  void _showLocationFilterDialog() async {
    final List<Map<String, dynamic>> districts = await fetchDistricts();

    final FilterC? updatedFilter = await showDialog<FilterC>(
      context: context,
      builder: (context) {
        return LocationDialog(
          initialFilter: widget.currentFilter,
          districts: districts,
          getPlaceDetails: _getPlaceDetails,
        );

      },
    );

    if (updatedFilter != null) {
      setState(() {
        widget.currentFilter = updatedFilter;
      });
      widget.onFilterChanged(widget.currentFilter);
    }
  }








  Future<List<Map<String, dynamic>>> fetchDistricts() async {
    try {
      final String apiKey = getApiKey(context);
      final endpoint = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
        'input': 'מחוז',
        'types': 'geocode', // optional: to get more specific results
        'components': 'country:IL', // Restrict results to Israel
        'language': 'iw', // Request results in Hebrew

        'key': apiKey,
      });


      final response = await http.get(endpoint);
      final data = json.decode(response.body);

      if (data['predictions'] != null) {
        return List<Map<String, dynamic>>.from(
          data['predictions'].map((prediction) => {
            'description': prediction['description'],
            'place_id': prediction['place_id'],
          }),
        );
      } else {
        throw Exception('Failed to fetch districts');
      }
    } catch (error) {
      rethrow;
    }
  }



  //function to get the lat and long based on a selected place_id:
  Future<Map<String, double>> _getPlaceDetails(String placeId) async {
    final String apiKey = getApiKey(context);
    final endpoint = Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
      'place_id': placeId,
      'fields': 'geometry',
      'key': apiKey,
    });

    final response = await http.get(endpoint);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['result'] != null && data['result']['geometry'] != null) {
        final location = data['result']['geometry']['location'];
        return {
          'lat': location['lat'],
          'lng': location['lng'],
        };
      }
    }
    throw Exception('Failed to fetch place details');
  }

}


class LocationDialog extends StatefulWidget {
  final FilterC initialFilter;
  final List<Map<String, dynamic>> districts;
  final Future<Map<String, double>> Function(String placeId) getPlaceDetails;

  const LocationDialog({super.key,
    required this.initialFilter,
    required this.districts,
    required this.getPlaceDetails,
  });

  @override
  _LocationDialogState createState() => _LocationDialogState();
}


class _LocationDialogState extends State<LocationDialog> {
  late FilterC _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter; // make a copy to avoid direct modification
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider for adjusting the radius
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Slider(
                  value: _currentFilter.radius,
                  onChanged: (double newValue) {
                    setState(() {
                      _currentFilter.radius = newValue;
                    });
                  },
                  min: 5.0,
                  max: 200.0,
                  divisions: 10,
                  label: _currentFilter.radius.round().toString(),
                ),
                Text("Radius: ${_currentFilter.radius.round()} km"),
              ],
            ),
          ),
          // List of districts
          ...widget.districts.map((district) {
            return ListTile(
              title: Text(district['description']),
              onTap: () async {
                final coordinates = await widget.getPlaceDetails(district['place_id']);
                _currentFilter.location = district['description'];
                _currentFilter.latitude = coordinates['lat'];
                _currentFilter.longitude = coordinates['lng'];
                _currentFilter.addTag('location', _currentFilter.location);
                Navigator.pop(context, _currentFilter); // return updated filter
              },
            );
          }).toList(),
        ],
      ),
    );
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

