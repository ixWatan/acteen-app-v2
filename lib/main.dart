import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'firebase_options.dart';
import 'log_in_screen.dart';
import 'home_page_organizations.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  //This is the entry point of your Flutter application.
  // The main function is where the execution of your app starts.
  // The async keyword indicates that this function can perform operations asynchronously,
  // meaning it can perform tasks in the background and doesn't block the main thread.

  WidgetsFlutterBinding.ensureInitialized();
  //This line of code initializes the binding between the widgets layer and the Flutter engine.
  // It is necessary to call this method if you're going to call any Flutter code before calling runApp(),
  // especially if you're initializing plugins that might interact with the Flutter framework.

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //This line initializes the Firebase SDK with the default options for the current platform (iOS/Android/Web).
  // It's an asynchronous operation, hence it is prefixed with await to wait for the operation to complete before moving to the next line of code.
  // Initializing Firebase is a prerequisite before using any Firebase services in your app.

  runApp(const MyApp());
  //This line of code calls the runApp function, which inflates the given widget and attaches it to the screen.
  // In this case, it's inflating the MyApp widget, which is typically where you define the root structure of your app.
  // The const keyword is used here to indicate that MyApp is a constant and won't change over time, allowing Flutter to optimize the build process.
}


class MyApp extends StatelessWidget {
  //Here, a new class named MyApp is defined which extends StatelessWidget.
  // A StatelessWidget is a widget that describes part of the user interface by building a constellation of other widgets that describe the user interface more concretely.
  // The StatelessWidget is immutable, meaning the properties of the widget cannot change once set.

  const MyApp({super.key});
//This is the constructor for the MyApp class.
// It is marked as const, which means that it can create compile-time constants if all of its arguments are compile-time constants.
// It takes an optional named parameter key which is passed to the superclass (StatelessWidget) using super.key.
// The key is used to control the framework's widget replacement and reuse during the widget tree rebuild process.

  @override
  //This annotation indicates that the following method (build) overrides a method defined in a superclass.

  Widget build(BuildContext context) {
    //This is the build method that is overridden from the StatelessWidget class.
    // It takes a BuildContext object as a parameter, which contains the context in which this widget is being built.
    // The build method is called by the framework to generate the widget tree.

    return const MaterialApp(
      home: RootPage(),
    );
    //The home property of MaterialApp is set to an instance of RootPage widget, which means RootPage will be the first screen displayed when the app launches.
    //The RootPage widget would be where you define the behavior for checking the authentication state and navigating to the appropriate page (like a login or home page).

  }
}


//MyApp

//--------------------------------------------------------------------------------

//MyHomePage


class MyHomePage extends StatefulWidget {
  //Here, a new class named MyHomePage is defined which extends StatefulWidget.
  // A StatefulWidget is a widget that has mutable state.
  // The state is stored in a separate object (_MyHomePageState in this case) which allows the widget to be rebuilt with new state.

  const MyHomePage({super.key, required this.title});
  //This is the constructor for the MyHomePage class. It takes two parameters:
  //
  // An optional key parameter which is passed to the superclass (StatefulWidget) using super.key.
  // A required named parameter title of type String. The required keyword indicates that this parameter must be supplied when creating an instance of MyHomePage.

  final String title;
  //This line declares a final variable title of type String.
  // Being final, its value must be set at the time of construction and cannot be changed later.

  @override
  State<MyHomePage> createState() => _MyHomePageState();
  //This method overrides the createState method from the StatefulWidget class.
  //It returns a new instance of _MyHomePageState, which holds the mutable state for MyHomePage.
}

class _MyHomePageState extends State<MyHomePage> {
  //This class holds the state for MyHomePage. It extends State with a generic parameter of MyHomePage, indicating that this state is associated with the MyHomePage widget.


  @override
  Widget build(BuildContext context) {
    //This method overrides the build method from the State class.
    //It takes a BuildContext object as a parameter, which contains the context in which this widget is being built.
    //The build method is called by the framework to generate the widget tree.

    return Scaffold(
      appBar: AppBar(
      ),
      body: const Center(
      ),
    );
    //Inside the build method, a Scaffold widget is returned.
    // The Scaffold is a top-level container that holds the structure of the visual interface, like the AppBar and the body of the screen.
    // Here, it contains an AppBar widget (which can hold a toolbar, among other things) and a Center widget in the body (which centers its child widget).

  }
}

//MyHomePage


//-------------------------------------------------------------------------------- The RootPage class is a stateless widget that listens to authentication state changes from Firebase using a StreamBuilder.
// Depending on the current authentication state, it either shows a loading spinner, the home page, or the login page.
// This allows the app to dynamically show the appropriate page based on the user's authentication state, even reacting to changes in real-time (e.g., if the user logs in or out).

//RootPage
class RootPage extends StatelessWidget {
  //This line defines a new class named RootPage that extends StatelessWidget.
  // A StatelessWidget is a widget that does not have any mutable state, meaning its properties are immutable once set.

  const RootPage({super.key});
//This is the constructor for the RootPage class.
//It accepts an optional key parameter which is passed to the superclass (StatelessWidget) using super.key.

  @override
  Widget build(BuildContext context) {
    //This method overrides the build method from the StatelessWidget class.
    //It takes a BuildContext object as a parameter, which contains the context in which this widget is being built.
    //The build method is called by the framework to generate the widget tree.

    return StreamBuilder<User?>(
      //Here, a StreamBuilder widget is returned.
      //This widget listens to a Stream and asks the builder function to rebuild whenever it receives a new value from the Stream.
      //The generic type <User?> indicates that the Stream emits values of type User? (or null).

      stream: FirebaseAuth.instance.authStateChanges(),
      //This line sets the stream property of the StreamBuilder to listen to authentication state changes from Firebase.
      // Whenever the authentication state changes (e.g., a user logs in or out), this stream emits a new value, causing the builder function to be called.

      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        //This is the builder function that is called whenever the stream emits a new value.
        //It takes two parameters: the build context and a snapshot of the current stream value.
        //The snapshot contains information about the stream's current state and the current value (if any).

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }//If snapshot.connectionState is ConnectionState.waiting, it means that the stream is still waiting for a value,
        //so a Scaffold widget with a centered CircularProgressIndicator (a loading spinner) is returned.

        else if (snapshot.hasData) {
          return const HomePageOrganizations();  // Replace with your home page
        }
        //If snapshot.hasData is true, it means that the stream has emitted a non-null value,
        //indicating that a user is logged in. In this case, the HomePage widget is returned (you would replace this with your actual home page widget).

        else {
          return const LoginPage();
        }
        //Otherwise, the LoginPage widget is returned, indicating that no user is logged in.
      },
    );
  }
}

//--------------------------------------------------------------------------------


//OnboardingScreen

class OnboardingScreen extends StatefulWidget {
  //This line defines a new class named OnboardingScreen that extends StatefulWidget.
  //A StatefulWidget is a widget that has mutable state.
  //It can hold data that might change during the lifetime of the widget.

  const OnboardingScreen({super.key});
 //This is the constructor for the OnboardingScreen class.
  // It accepts an optional key parameter which is passed to the superclass (StatefulWidget) using super.key.
  // The const keyword indicates that this constructor can be invoked at compile-time to create a compile-time constant.

  @override
  //This annotation indicates that the following method overrides a method defined in a superclass.

  // ignore: library_private_types_in_public_api
  _OnboardingScreenState createState() => _OnboardingScreenState();
  //This method overrides the createState method from the StatefulWidget class.
  //It returns a new instance of _OnboardingScreenState, which holds the mutable state for this widget.
  //The createState method is called by the framework when it inflates this widget and needs to create the mutable state object.

}

class _OnboardingScreenState extends State<OnboardingScreen> {
  //The class _OnboardingScreenState extends State with a generic parameter OnboardingScreen,
  // indicating that it holds the state for the OnboardingScreen widget.

  bool showSelectionPage = false; // Add this variable
  //showSelectionPage is a boolean state variable that determines which set of pages (activist or organization) to display in the onboarding process.

  void selectActivist() {
    setState(() {
      showSelectionPage = false; // Update the variable
      selectionShowSelectionPage(); //navigate to the selectionShowSelectionPage
    });
  }

  void selectOrganization() {
    setState(() {
      showSelectionPage = true; // Update the variable
      selectionShowSelectionPage(); //navigate to the selectionShowSelectionPage
    });
  }

  //selectActivist and selectOrganization are methods that update the showSelectionPage state variable and navigate to the selection page.
  // They use setState to trigger a rebuild of the widget with the new state.


  void onDonePress() {
    // Navigate to the main screen when done
    Navigator.of(context).pushReplacementNamed('/main');
  }
  //onDonePress is a method that navigates to the main screen when the user completes the onboarding process.

  void selectionShowSelectionPage() {
    List<PageViewModel> pages;
    if (showSelectionPage) {
      pages = getOrganizationPages();
    } else {
      pages = getActivistPages();
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return IntroductionScreen(
        pages: pages,
        onDone: onDonePress, // Callback when done button is pressed
        done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
        next: const Icon(Icons.arrow_forward),
        skip: const Text("Skip"),
        showSkipButton: true,
      );
    }));
  }

  //This method decides which set of pages to display based on the showSelectionPage state variable and navigates to an IntroductionScreen with the selected pages.

//--------------------------------------------------------------------------------

  //These methods return lists of PageViewModel objects that represent the slides for the activist and organization onboarding flows, respectively.

  List<PageViewModel> getActivistPages() {
    return [
      PageViewModel(
        title: "Find an Opportunity!",
        body: "We’ve got a collection of over 100 activism opportunities for you to choose from!",
        image: Image.asset("assets/images/SlideShowActivist1.png",height: 200, width: 200),
      ),
      PageViewModel(
        title: "Sign Up!",
        body: "Sign up for the opportunity you would like to attend and connect it to your calendar so that you will be reminded of it before it happens.",
        image: Image.asset("assets/images/SlideShowActivist2-SlideShowOrganization1.png",height: 200, width: 200),
      ),
      PageViewModel(
        title: "Safety is #1",
        body: "Your safety is our top priority! Therefore, only approved organizations are allowed to post events on the app, and each user under 16 will sign a parental consent waiver",
        image: Image.asset("assets/images/SlideShowActivist3.png",height: 200, width: 200),
      ),
      PageViewModel(
        title: "Attend!",
        body: "We’ve had many teens enjoy their experiences at different activism opportunities and give back to their communities!",
        image: Image.asset("assets/images/SlideShowActivist4.png",height: 200, width: 200),
      ),
      PageViewModel(
        title: "Become the activist that you have always wanted to be!",
        body: "Find your perfect match with the right activism opportunity for you!",
        image: Image.asset("assets/images/FinalSlide.png",height: 200, width: 200),
      ),
      // Slides for activists
    ];
  }


  List<PageViewModel> getOrganizationPages() {
    return [
      PageViewModel(
        title: "Sign Up",
        body: "Sign up as a registered organization through our app’s registration form",
        image: Image.asset("assets/images/SlideShowActivist2-SlideShowOrganization1.png",height: 200, width: 200),
      ),
      PageViewModel(
        title: "Create Posts",
        body: "Use our post templates to upload your events to the Acteen community for others to see and attend.",
        image: Image.asset("assets/images/SlideShowOrganization2.png",height: 200, width: 200),
      ),
      PageViewModel(
        title: "Manage Campaigns",
        body: "We give each organization the opportunity to view the analytics for their campaigns and manage them in an easy way. These features will help you manage your campaign in a more efficient way.",
        image: Image.asset("assets/images/SlideShowOrganization3.png",height: 200, width: 200),
      ),
      PageViewModel(
        title: "Get Started",
        body: "Start posting your opportunities today!",
        image: Image.asset("assets/images/FinalSlide.png",height: 200, width: 200),
      ),

    ];
  }

  //---------------------------------------------------------------------------------
  //The build method defines the widget tree for the initial onboarding screen.
  // It includes an image, some text, and two buttons that allow the user to select whether they are an activist or an organization.
  // The buttons are linked to the selectActivist and selectOrganization methods, which will trigger the respective onboarding flows.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200.0, // or any size you want
              width: 200.0, // or any size you want
              child: Image.asset('assets/images/ActeenLogo.png', fit: BoxFit.cover),
            ),
            // Adjust height and width as needed
            const Text("Welcome To Acteen!"),
            const Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Center(
                    child: Text(
                      "The app that connects teens to activism opportunities in their area, making activism easy and accessible.",
                      textAlign: TextAlign.center, // Center the text
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ElevatedButton(
                    onPressed: selectActivist,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 50), // Set minimum width and height
                    ),// Call selectActivist method
                    child: const Text("I'm an Activist"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ElevatedButton(
                    onPressed: selectOrganization,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 50), // Set minimum width and height
                    ),// Call selectOrganization method
                    child: const Text("I'm an Organization"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
//----------------------------------------------------------------------------------------

