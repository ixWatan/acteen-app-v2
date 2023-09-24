import 'package:flutter/material.dart';
import '../log_in_screen.dart';
import 'create_event_page.dart';

// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';

class HomePageOrganizations extends StatelessWidget {
  //HomePage is a class that extends StatelessWidget, indicating that this widget does not have a mutable state.

  const HomePageOrganizations({super.key});
  //It accepts a key as a parameter in its constructor, which is passed to the superclass constructor.0

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Navigate to the login page
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      // Handle sign-out errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()), // Display the error message
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //_signOut is a method that attempts to sign out the user from Firebase Authentication. It is an asynchronous method, denoted by async, and returns a Future<void>.
  //It uses a try-catch block to handle any errors that might occur during the sign-out process.
  //If an error occurs, it can be handled in the catch block (currently, errors are not handled).


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Home Page Organizations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  const CreateEventPage()),
                );
              },
              child:  const Text('Create New Post'),
            ),
          ],
        ),
      ),
    );
  }
}






