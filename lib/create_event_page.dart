// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'config.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateEventPageState createState() => _CreateEventPageState();
}




class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _selectedImage;
  LatLng? _selectedLocation;
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

  Future<void> _selectLocation() async {
    String apiKey = getApiKey(context);
    GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: apiKey);
    try {
      Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: apiKey,
        mode: Mode.overlay, // or Mode.fullscreen
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
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _selectImage,
              child: const Text('Select Image'),
            ),
            if (_selectedImage != null)
              Image.file(
                File(_selectedImage!.path),
                height: 200,
                width: 200,
              ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectLocation(),
              child: const Text('Select Location'),
            ),
            if (_selectedLocation != null)
              Text('Selected location: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectDate(context, true),
              child: const Text('Select Start Date'),
            ),
            if (_startDate != null) Text('Selected date: ${_startDate!.toLocal()}'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectTime(context, true),
              child: const Text('Select Start Time'),
            ),
            if (_startTime != null) Text('Selected time: ${_startTime!.format(context)}'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectDate(context, false),
              child: const Text('Select End Date'),
            ),
            if (_endDate != null) Text('Selected date: ${_endDate!.toLocal()}'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectTime(context, false),
              child: const Text('Select End Time'),
            ),
            if (_endTime != null) Text('Selected time: ${_endTime!.format(context)}'),
          ],
        ),
      ),
    );
  }
}
