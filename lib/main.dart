import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fyp/Core/config/dimensions.dart';
import 'package:fyp/Screens/homeScreen.dart';
import 'package:fyp/Screens/myAppointments.dart';
import 'package:fyp/Screens/signIn.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      name: 'final project',
      options: const FirebaseOptions(
          appId: '1:201017378885:android:91bb9b88ca8b98e9f47b2c',
          apiKey: 'AIzaSyBaPOGgycLamuvQVXfEc53usmrlIB8Tc3w',
          messagingSenderId: '201017378885',
          projectId: 'final-project-e6c97'));

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Medic",
    theme: ThemeData(
      fontFamily: "regular",
      appBarTheme: const AppBarTheme(
        iconTheme:
            IconThemeData(color: Colors.white), // change the icon color here
        color: Colors.white, // change the appbar background color here
      ),
    ),
    home: const MyProject(),
  ));
}

class MyProject extends StatefulWidget {
  const MyProject({super.key});
  @override
  State<MyProject> createState() => _MyProjectState();
}

class _MyProjectState extends State<MyProject> {
  @override
  void initState() {
    super.initState();
    gotonextscreen();
  }

  // gotonextscreen() async {
  //   Timer(const Duration(seconds: 5), () {
  //     if (FirebaseAuth.instance.currentUser != null) {
  //       FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(FirebaseAuth.instance.currentUser!.uid)
  //           .get()
  //           .then((value) {
  //         if (value.exists) {
  //           // Check if the user is a doctor
  //           bool isDoctor = value.data()!['isDoctor'] ??
  //               false; // Assuming there is a field 'isDoctor' in your user document
  //           if (isDoctor) {
  //             // User is a doctor, navigate to myApp screen
  //             Navigator.pushReplacement(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) => const myAppSc(isUser: false)));
  //           } else {
  //             // User is not a doctor, navigate to home screen
  //             Navigator.pushReplacement(context,
  //                 MaterialPageRoute(builder: (context) => const MyHome2()));
  //           }
  //         } else {
  //           // User document does not exist, navigate to login screen
  //           Navigator.pushReplacement(context,
  //               MaterialPageRoute(builder: (context) => const logIn()));
  //         }
  //       });
  //     } else {
  //       // User is not authenticated, navigate to login screen
  //       Navigator.pushReplacement(
  //           context, MaterialPageRoute(builder: (context) => const logIn()));
  //     }
  //   });
  // }
  gotonextscreen() async {
    final app = Firebase.app('final project'); // Get the custom Firebase app
    final auth =
        FirebaseAuth.instanceFor(app: app); // Use the custom app instance
    final firestore = FirebaseFirestore.instanceFor(app: app);

    Timer(const Duration(seconds: 5), () {
      if (auth.currentUser != null) {
        firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get()
            .then((value) {
          if (value.exists) {
            bool isDoctor = value.data()!['isDoctor'] ?? false;
            if (isDoctor) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const MyAppointmentsScreen(isUser: false)));
            } else {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()));
            }
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const SignInScreen()));
          }
        });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SignInScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final dimensions = Dimensions(context);
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 146, 249, 254),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 3, 75, 109),
              Color.fromARGB(255, 7, 97, 139),
              Color.fromARGB(255, 39, 128, 170),
              Color.fromARGB(255, 100, 178, 214),
              Color.fromARGB(255, 162, 207, 228),
              Color.fromARGB(255, 252, 253, 253),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.30),
              Image.asset(
                "assets/images/AppImages/applogo.png",
                height: screenHeight * 0.1,
                width: screenWidth * 0.2,
              ),
              SizedBox(height: screenHeight * 0.02),
              const Text(
                "Medic",
                style: TextStyle(
                    // color: Colors.white,
                    color: Color.fromARGB(255, 3, 75, 109),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none),
              ),
              SizedBox(height: screenHeight * 0.05),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  Color.fromARGB(255, 3, 75, 109),
                ),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
