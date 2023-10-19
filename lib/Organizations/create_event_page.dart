// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, duplicate_ignore
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

//These lines import the necessary packages and libraries. For instance, it imports Flutter's material design library,
//an HTTP client library (http), JSON decoding support, file I/O functionalities, and various Firebase packages.

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateEventPageState createState() => _CreateEventPageState();
}
//CreateEventPage is declared as a StatefulWidget, indicating that its content might change over time.
// The constructor accepts a key parameter which is passed to the superclass.
// createState method returns an instance of _CreateEventPageState, which holds the mutable state for this widget.

String? selectedLocation;

//This section defines the state class _CreateEventPageState and declares various member variables:
//
// TextEditingControllers: Controllers (_locationController, _titleController, and _descriptionController) to control the text input fields.
// _locationSuggestions: A list to store location suggestions fetched from the Google Places API.
// _selectedImage: Stores the selected image file.
// _startDate, _startTime, _endDate, _endTime: Variables to store the selected start and end dates and times for the event.
// _picker: An instance of ImagePicker to facilitate image picking from the gallery.

class _CreateEventPageState extends State<CreateEventPage> {

  final TextEditingController _locationController = TextEditingController();
  List<Map<String, dynamic>> _locationSuggestions = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _selectedImage;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  double? _selectedLat;
  double? _selectedLng;

  final ImagePicker _picker = ImagePicker();

  final List<String> _hashtags = [
    'Hashtag1',
    'Hashtag2',
    'Hashtag3',
    'Hashtag4',
    'Hashtag5',
  ];
  final Set<String> _selectedHashtags = {};

  Future<void> _selectImage() async {  //_selectImage: Opening the image picker and updating _selectedImage with the picked image.

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = image;
    });
  }



  Future<void> _selectDate(BuildContext context, bool isStart) async {  // _selectDate: Displaying a date picker dialog and updating either _startDate or _endDate based on the isStart parameter.

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {  // _selectTime: Displaying a time picker dialog and updating either _startTime or _endTime based on the isStart parameter.

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null)
      // ignore: curly_braces_in_flow_control_structures
      setState(() {
        if (isStart) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
  }

  Future<String?> addEventToDatabase() async {
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('images')
            .child('${DateTime.now().toIso8601String()}.png');

        await ref.putFile(File(_selectedImage!.path));
        imageUrl = await ref.getDownloadURL(); // Get the URL of the uploaded image
      }

      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        Map<String, dynamic> eventData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'imagePath': imageUrl,
          'location': selectedLocation,
          'startDate': _startDate?.toIso8601String(),
          'startTime': _startTime?.format(context),
          'endDate': _endDate?.toIso8601String(),
          'endTime': _endTime?.format(context),
          'hashtags': _selectedHashtags.toList(),
          'userId': userId,
          'latitude': _selectedLat,
          'longitude': _selectedLng,
          'likesCount': 0, // initializing with 0
          'likedByUserIds': [], // initializing with an empty list
          'attendeesCount': 0, // initializing with 0
          'attendedByUserIds': [], // initializing with an empty list
        };


        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('organizations')
            .doc(userId)
            .collection('events')
            .add(eventData);

        // Update the event data with the generated postId
        eventData['postId'] = docRef.id;

        // Update the document in the user's organization's events collection with the postId
        await FirebaseFirestore.instance
            .collection('organizations')
            .doc(userId)
            .collection('events')
            .doc(docRef.id)
            .update({'postId': docRef.id});

        // Additionally adding event to the main_events collection
        // You should also update the main_events collection's document with the postId
        DocumentReference mainEventDocRef = await FirebaseFirestore.instance
            .collection('main_events')
            .add(eventData);

        await FirebaseFirestore.instance
            .collection('main_events')
            .doc(mainEventDocRef.id)
            .update({'postId': mainEventDocRef.id});

        return docRef.id; // Returning the event ID
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
      return null; // Return null if there is an exception
    }
    return null;
  }






  // Fetch location suggestions from the Google Places Autocomplete API
  void _getPlaceSuggestions(String input) async {//_getPlaceSuggestions: Fetches location suggestions from the Google Places API and updates _locationSuggestions.
    try {
      final String apiKey = getApiKey(context);
      final endpoint = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
        'input': input,
        'key': apiKey,
      });

      final response = await http.get(endpoint);
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['predictions'] != null) {
        final List<Map<String, dynamic>> suggestions = List<Map<String, dynamic>>.from(
            data['predictions'].map((prediction) => {
              'description': prediction['description'],
              'place_id': prediction['place_id']
            })
        );
        setState(() {
          _locationSuggestions = suggestions;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching data: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $error'),
          backgroundColor: Colors.red,
        ),
      );
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



  //This part defines the build method which constructs the UI of the CreateEventPage. It contains a lot of widgets such as TextField, ElevatedButton, Image.file, DatePicker, TimePicker, and a ListView to arrange these widgets in a scrollable list.
  //
  // Inside this method, it:
  //
  // Constructs text fields with appropriate controllers and input decorations.
  // Offers functionality to clear text input and fetch location suggestions dynamically.
  // Provides buttons to open the image picker and date/time pick




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Flexible(
          child: ListView(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min, // this will take the minimum space that is needed
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _titleController.clear();
                          setState(() {
                            _titleController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _selectImage,
                child: const Text('Select Image'),
              ),
              if (_selectedImage != null)
                Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Image.file(
                          File(_selectedImage!.path),
                          height: 300,
                          width: 300,
                          fit: BoxFit.cover,  // This will make the image fill the container
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),


              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min, // this will take the minimum space that is needed
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _descriptionController.clear();
                          setState(() {
                            _descriptionController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min, // this will take the minimum space that is needed
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _locationController.clear();
                        },
                      ),
                    ],
                  ),
                ),
                onChanged: (value) {
                  // Update location suggestions when the user types
                  _getPlaceSuggestions(value);
                },
              ),

              // Display location suggestions as a dropdown menu
              if (_locationSuggestions.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Column(
                    children: _locationSuggestions.map((location) {
                      return ListTile(
                        title: Text(location['description']),
                        onTap: () async {
                          final coordinates = await _getPlaceDetails(location['place_id']);
                          setState(() {
                            _locationController.text = location['description'];
                            selectedLocation = location['description'];
                            _selectedLat = coordinates['lat'];
                            _selectedLng = coordinates['lng'];
                            _locationSuggestions.clear(); // Clear suggestions
                          });
                        },


                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 10),

              // Start Date Picker
              TextField(
                readOnly: true,
                controller: TextEditingController(text: _startDate != null ? _startDate!.toLocal().toString() : ''),
                decoration: InputDecoration(
                  labelText: 'Select Start Date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, true),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Start Time Picker
              TextField(
                readOnly: true,
                controller: TextEditingController(text: _startTime != null ? _startTime!.format(context) : ''),
                decoration: InputDecoration(
                  labelText: 'Select Start Time',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selectTime(context, true),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // End Date Picker
              TextField(
                readOnly: true,
                controller: TextEditingController(text: _endDate != null ? _endDate!.toLocal().toString() : ''),
                decoration: InputDecoration(
                  labelText: 'Select End Date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, false),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // End Time Picker
              TextField(
                readOnly: true,
                controller: TextEditingController(text: _endTime != null ? _endTime!.format(context) : ''),
                decoration: InputDecoration(
                  labelText: 'Select End Time',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selectTime(context, false),
                  ),
                ),
              ),
              const SizedBox(height: 10),


              DropdownButtonFormField(
                items: _hashtags
                    .map((hashtag) => DropdownMenuItem(
                  value: hashtag,
                  child: Text(hashtag),
                ))
                    .toList(),
                onChanged: (value) {
                  if (_selectedHashtags.length < 3) {
                    setState(() {
                      _selectedHashtags.add(value as String);
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You can select up to 3 hashtags'),
                          backgroundColor: Colors.red,
                        ),
                    );
                  }
                },
                hint: const Text('Select a hashtag'),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8.0,
                children: _selectedHashtags
                    .map((hashtag) => Chip(
                  label: Text(hashtag),
                  onDeleted: () {
                    setState(() {
                      _selectedHashtags.remove(hashtag);
                    });
                  },
                ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: addEventToDatabase,
                child: const Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
