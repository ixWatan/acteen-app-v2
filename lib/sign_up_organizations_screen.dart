import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'log_in_screen.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page_organizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPageActivists extends StatefulWidget {
  //SignUpPage is a class that extends StatefulWidget, indicating that this widget maintains a mutable state.

  const SignUpPageActivists({super.key});
  //It accepts a key as a parameter in its constructor, which is passed to the superclass constructor.

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
//The createState method is overridden to return an instance of _SignUpPageState, which contains the mutable state for this widget.
}

class _SignUpPageState extends State<SignUpPageActivists> {
  //_SignUpPageState is a private class that holds the state for the SignUpPage widget.

  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  //It defines three instance variables: _auth (an instance of FirebaseAuth),
  //_emailController, and _passwordController (both are instances of TextEditingController to control the text fields for email and password inputs).

  Future<void> _signUp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Add user details to Firestore
      CollectionReference users = FirebaseFirestore.instance.collection('organizations');
      users.add({
        'email': _emailController.text.trim(),
        // add other details here
      });

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePageOrganizations()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
