import 'dart:io' show Platform;
import 'package:flutter/material.dart';

String getApiKey(BuildContext context) {
  if (Platform.isAndroid) {
    return 'AIzaSyCwDRpRqXcBObehKRVJqW4-gZqpiwjhwYs';
  } else if (Platform.isIOS) {
    return 'AIzaSyDIy4rQVfGcfLPpkID2MX6C5lbI_tV03SM';
  } else {
    // Display a SnackBar for unsupported platforms
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unsupported platform'),
        backgroundColor: Colors.red,
      ),
    );
    return ''; // Return an empty string or handle it accordingly
  }
}
