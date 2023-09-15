// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'config.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateEventPageState createState() => _CreateEventPageState();
}




class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _locationController = TextEditingController();
  LatLng? _selectedLocation;
  List<String> _locationSuggestions = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _selectedImage;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  final ImagePicker _picker = ImagePicker();

  Future<void> _selectImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = image;
    });
  }



  Future<void> _selectDate(BuildContext context, bool isStart) async {
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

  Future<void> _selectTime(BuildContext context, bool isStart) async {
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

  Future<void> addEventToDatabase() async {
    try {
      await FirebaseFirestore.instance.collection('events').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'imagePath': _selectedImage?.path, // You might want to upload the image to a server and store the URL instead
        'location': {
          'latitude': _selectedLocation?.latitude,
          'longitude': _selectedLocation?.longitude,
        },
        'startDate': _startDate?.toIso8601String(),
        'startTime': _startTime?.format(context),
        'endDate': _endDate?.toIso8601String(),
        'endTime': _endTime?.format(context),
        'userId': 'logged_in_user_id', // Replace with the actual user ID
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


 /* Future<void> _selectLocation() async {
    try {
      final apiKey = getApiKey(context);
      final places = GoogleMapsPlaces(apiKey: apiKey);

      final Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: apiKey,
        mode: Mode.overlay,
        language: "en",
        components: [Component(Component.country, "us")],
      );

      if (p != null) {
        PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);
        double lat = detail.result.geometry!.location.lat;
        double lng = detail.result.geometry!.location.lng;
        setState(() {
          _selectedLocation = LatLng(lat, lng);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }*/



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        // You might also want to clear the location suggestions here
                        setState(() {
                          _locationSuggestions.clear();
                        });
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
                      title: Text(location),
                      onTap: () {
                        // Set the selected location when the user taps a suggestion
                        setState(() {
                          _locationController.text = location;
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
          ],
        ),
      ),
    );
  }


  // Fetch location suggestions from the Google Places Autocomplete API
  void _getPlaceSuggestions(String input) async {
    try {
      final String apiKey = getApiKey(context);
      final endpoint = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
        'input': input,
        'key': apiKey,
      });

      final response = await http.get(endpoint);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['predictions'] != null) {
          final List<String> suggestions = List<String>.from(data['predictions'].map((prediction) => prediction['description']));
          setState(() {
            _locationSuggestions = suggestions;
          });
        }
      } else {
        // ignore: use_build_context_synchronously
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

}
