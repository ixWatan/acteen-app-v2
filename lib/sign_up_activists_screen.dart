// ignore_for_file: use_build_context_synchronously

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

  Future<void> _signUp() async {
    //You're declaring a method named _signUp that is asynchronous (meaning it can perform operations that might take some time to complete,
    //like network requests) and returns a Future that resolves to void (i.e., it doesn't return a value).

    try {//A try block is initiated. The code inside this block is executed, and if any error occurs, it jumps to the catch blocks to handle the error.
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      //A call is made to the createUserWithEmailAndPassword method of the _auth object (an instance of FirebaseAuth).
      //This method attempts to create a new user with the email and password retrieved from the respective text controllers. The await keyword is used to wait for this operation to complete before moving to the next line. The result (a UserCredential object) is stored in the variable userCredential.

      String userId = userCredential.user!.uid;
      //You're retrieving the unique ID (uid) of the newly created user from the userCredential object and storing it in the userId variable.

      // Add user details to Firestore
      CollectionReference users = FirebaseFirestore.instance.collection('activists');
      users.doc(userId).set({
        'uid': userId,
        'email': _emailController.text.trim(),
        // add other details here
      });
      //You're setting up a reference to the 'activists' collection in Firestore and using the set method to create a new document with the user's ID as the document ID, and setting the fields uid and email in that document.

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePageActivists()),
      );
      //After successfully creating the user and saving the details to Firestore, you're navigating to the HomePageActivists screen using Navigator.push.

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
    //If any error occurs during the execution of the code inside the try block, these catch blocks will handle them.
    //The first catch block handles errors of type FirebaseAuthException, displaying a snackbar with the error message. The second catch block handles any other types of errors, displaying a snackbar with a generic error message.
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
}//This marks the end of the _signUp method.




