// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test/Organizations/sign_up_organizations_screen.dart';
import 'Organizations/home_page_organizations.dart';
import 'Activists/home_page_activists.dart';
import 'Activists/sign_up_activists_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MyApp());
}
//This is the entry point of the Flutter application.
// It calls the runApp function with an instance of MyApp as an argument to start the application.

class MyApp extends StatelessWidget {
  //MyApp is a class that extends StatelessWidget, indicating that this widget does not maintain any mutable state.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),
    );
  }
  //it contains a build method that returns a MaterialApp widget with LoginPage as its home, meaning LoginPage will be the first screen displayed when the app launches.
}


class LoginPage extends StatefulWidget {
  //LoginPage is a class that extends StatefulWidget, indicating that this widget maintains a mutable state.

  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
  //It overrides the createState method to return an instance of _LoginPageState, which contains the mutable state for this widget.
}

class _LoginPageState extends State<LoginPage> {
  //_LoginPageState is a private class that holds the state for the LoginPage widget.
  //It contains a method _login which is responsible for handling the login process using Firebase Authentication.
  //The build method defines the UI structure of the login page.

  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  //It defines three instance variables: _auth (an instance of FirebaseAuth),
  //_emailController, and _passwordController (both are instances of TextEditingController to control the text fields for email and password inputs).

  Future<void> _login() async {//This declares a method named _login that is asynchronous (meaning it can perform operations that might take some time to complete) and returns a Future that resolves to void (i.e., it doesn't return a value).
    try {//A try block is initiated. The code inside this block is executed, and if any error occurs, it jumps to the catch blocks to handle the error.
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      //A call is made to the signInWithEmailAndPassword method of the _auth object to sign in the user with the email and password retrieved from the respective text controllers.
      //The await keyword is used to wait for this operation to complete before moving to the next line.

      final userId = FirebaseAuth.instance.currentUser?.uid;
      //final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {//If userId is not null (meaning a user is logged in), the following code inside this block is executed.
        DocumentSnapshot activistData = await FirebaseFirestore.instance.collection('activists').doc(userId).get();
        DocumentSnapshot organizationData = await FirebaseFirestore.instance.collection('organizations').doc(userId).get();
        //You're fetching the document data from both the 'activists' and 'organizations' collections in Firestore where the document ID matches the current user's ID.

        if (activistData.exists) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePageActivists()),
          );
        } else if (organizationData.exists) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePageOrganizations()),
          );
        } else {
          //Based on the retrieved data, you're checking if the user exists in the 'activists' collection or the 'organizations' collection, and navigating to the respective home page accordingly.
          //If the user does not exist in either collection, the code inside the following block will be executed.
          // Handle case where user doesn't exist in either collection
          // Maybe show a snackbar with an error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not found in either collection'),
              backgroundColor: Colors.red,
            ),
          );
        }//If the user doesn't exist in either collection, a snackbar is displayed with an error message indicating that the user was not found in either collection.
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
    //If any error occurs during the execution of the code inside the try block, this catch block will handle it.
    //It catches errors of type FirebaseAuthException and displays a snackbar with the respective error message.
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
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
            //The email and password text fields are controlled by _emailController and _passwordController respectively.
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            //The "Login" button triggers the _login method when pressed, and the "
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPageOrganizations()),
                );
              },
              child: const Text('Go to Sign Up Activists'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPageActivists()),
                );
              },
              child: const Text('Go to Sign Up Organizations'),
            ),
          ],
        ),
      ),
    );    //It returns a Scaffold widget with an AppBar titled "Login Page" and a body that contains a column of widgets including text fields for email and password inputs, and buttons for the login process and navigating to the sign-up page.
  }
}//This marks the end of the _login method.






