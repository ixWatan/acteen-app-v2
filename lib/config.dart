import 'dart:io' show Platform;
import 'package:flutter/material.dart';
//You are importing two libraries:
// The dart:io library, but you are only importing the Platform class from it, which allows you to identify the OS (Operating System) on which the app is running.
// The flutter/material.dart package, which contains the Material Design widgets and other related classes.

String getApiKey(BuildContext context) {//This defines a function named getApiKey that takes a BuildContext as a parameter and returns a String.
  //BuildContext is a reference to the location of a widget within the tree structure of all the widgets that are built.

  if (Platform.isAndroid) {
    return 'AIzaSyCwDRpRqXcBObehKRVJqW4-gZqpiwjhwYs';
  } else if (Platform.isIOS) {
    return 'AIzaSyDIy4rQVfGcfLPpkID2MX6C5lbI_tV03SM';
  } else {
    //You are checking which platform the app is running on:
    // If it's running on Android, it returns a specific API key (a string that is used to authenticate requests to an API).
    // If it's running on iOS, it returns a different API key.
    // If the platform is neither Android nor iOS, the code inside the following block is executed.
    // Display a SnackBar for unsupported platforms
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unsupported platform'),
        backgroundColor: Colors.red,
      ),
    );
    return ''; // Return an empty string or handle it accordingly
  }
  //If the platform is neither Android nor iOS (like web or desktop), a SnackBar is displayed to notify the user that the platform is unsupported.
  //After displaying the SnackBar, the function returns an empty string.
  //This case handles platforms that are not supported by your application.
}
