import 'package:flutter/material.dart';
import 'package:test/home_page_activists.dart';
// ignore: depend_on_referenced_packages
import 'log_in_screen.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPageOrganizations extends StatefulWidget {
  //SignUpPage is a class that extends StatefulWidget, indicating that this widget maintains a mutable state.

  const SignUpPageOrganizations({super.key});
  //It accepts a key as a parameter in its constructor, which is passed to the superclass constructor.

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
  //The createState method is overridden to return an instance of _SignUpPageState, which contains the mutable state for this widget.
}

class _SignUpPageState extends State<SignUpPageOrganizations> {
  //_SignUpPageState is a private class that holds the state for the SignUpPage widget.

  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  //It defines three instance variables: _auth (an instance of FirebaseAuth),
  //_emailController, and _passwordController (both are instances of TextEditingController to control the text fields for email and password inputs).

  Future<void> _signUp() async { //This declares an asynchronous method named _login that returns a Future<void>. The async keyword indicates that the method contains asynchronous operations.
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      //Inside a try block, the method attempts to log in a user using Firebase Authentication.
      //It calls the signInWithEmailAndPassword method of the _auth object (which is an instance of FirebaseAuth).
      //The email and password for the login are retrieved from the _emailController and _passwordController text controllers, respectively.

      // Add user details to Firestore
      CollectionReference users = FirebaseFirestore.instance.collection('activists');
      users.add({
        'email': _emailController.text.trim(),
        // add other details here
      });

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePageActivists()),
      );
      //If the login attempt is successful, the method navigates the user to the HomePageOrganizations screen.
      //This is done using the Navigator.push method, which pushes a new route (in this case, HomePageOrganizations) onto the navigation stack.

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
    //If there's an error during the login attempt, it's caught by the catch block.
    //Specifically, it catches errors of type FirebaseAuthException. When such an error occurs, a SnackBar is displayed to the user with the error message.
    //If the exception doesn't provide a specific message, the default message 'An error occurred' is shown.
  }


  @override
  Widget build(BuildContext context) {
    //If an error occurs (caught by FirebaseAuthException), it displays a SnackBar with the error message.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            //It returns a Scaffold widget with an AppBar titled "Sign Up Page" and a body that contains a column of widgets including text fields for email and password inputs,
            //and buttons for the sign-up process and navigating to the login page.
            //The email and password text fields are controlled by _emailController and _passwordController respectively.
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Go to Login'),
            ),
            //The "Sign Up" button triggers the _signUp method when pressed, and the "Go to Login" button navigates to the LoginPage when pressed.
          ],
        ),
      ),
    );
  }
}



