// // ignore: file_names
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/Screens/homeScreen.dart';
import 'package:fyp/Screens/myAppointments.dart';
import 'package:fyp/Screens/signUp.dart';



class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var formkey = GlobalKey<FormState>();
  var isvalid = false;
  var isDoctor = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email == ("") || password == ("")) {
      log("Please fill all the details!");
    } else {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        if (userCredential.user != null) {
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => isDoctor
                      ? const MyAppointmentsScreen(isUser: false)
                      : const HomeScreen()));
        }
      } catch (e) {
        if (e is TypeError) {
          log(e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 146, 249, 254),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              // Color.fromARGB(255, 146, 249, 254),
              // Color.fromARGB(255, 195, 243, 242),
              // Color.fromARGB(255, 214, 250, 255),
              // Color.fromARGB(255, 146, 249, 254),
              Color.fromARGB(255, 7, 97, 137),

              Color.fromARGB(255, 254, 255, 255),
              // Color.fromARGB(255, 254, 255, 255),

              Color.fromARGB(255, 116, 168, 190),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.05),
          child: ListView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            children: [
              SizedBox(
                height: screenHeight * 0.35,
                width: screenWidth * 0.7,
                child: Image.asset(
                  "assets/images/AppImages/signIn.png",
                  alignment: Alignment.topCenter,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 28),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 11, 77, 105),
                  ),
                  // textAlign: TextAlign.center,
                ),
              ),
              // const SizedBox(height: 1),
              const Padding(
                padding: EdgeInsets.only(left: 28, right: 20),
                child: Text(
                  "Please enter your email and   password access your account",
                  style: TextStyle(
                    fontSize: 15,
                    // fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 133, 143, 148),
                  ),
                  // textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Form(
                key: formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.01),
                      child: Container(
                        // height: 45,
                        height: screenHeight * 0.06,
                        width: screenWidth * 0.88,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color.fromARGB(255, 238, 235, 235),
                                width: 1.0),
                            borderRadius: BorderRadius.circular(16),
                            color: const Color.fromARGB(255, 255, 255, 255),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color.fromARGB(255, 221, 218, 218),
                                  offset: Offset(02, 03),
                                  blurRadius: 0.5,
                                  spreadRadius: 0.1),
                            ]),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.name,
                          textAlign: TextAlign.justify,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter your email";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 11, 77, 105),
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Color.fromARGB(255, 11, 77, 105),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.015),
                      child: Container(
                        height: screenHeight * 0.06,
                        width: screenWidth * 0.88,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color.fromARGB(255, 207, 206, 206),
                                width: 1.0),
                            borderRadius: BorderRadius.circular(16),
                            color: const Color.fromARGB(255, 167, 206, 224),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color.fromARGB(255, 207, 206, 206),
                                  offset: Offset(02, 03),
                                  blurRadius: 0.5,
                                  spreadRadius: 0.1),
                            ]),
                        child: TextFormField(
                          controller: _passwordController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter your password";
                            }
                            return null;
                          },
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 11, 77, 105),
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Color.fromARGB(255, 11, 77, 105),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: SwitchListTile(
                    activeColor: const Color.fromARGB(255, 11, 77, 105),
                    title: const Text(
                      "Sign in as doctor",
                      style: TextStyle(
                          color: Color.fromARGB(255, 11, 77, 105),
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                    value: isDoctor,
                    onChanged: (value) {
                      setState(() {
                        isDoctor = value;
                      });
                    }),
              ),
              const SizedBox(
                height: 50,
              ),
              // TextButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => const signUpSc()),
              //     );
              //   },
              //   child: const Text(
              //     "Forgot password?",
              //     style: TextStyle(color: Color.fromARGB(255, 11, 77, 105), fontWeight: FontWeight.bold, fontSize: 17),
              //     textAlign: TextAlign.right,
              //   ),
              // ),
              // SizedBox(height: screenHeight * 0.01),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Container(
                  height: screenHeight * 0.06,
                  width: screenWidth * 0.88,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 11, 77, 105),
                          width: 1.0),
                      borderRadius: BorderRadius.circular(16),
                      color: const Color.fromARGB(255, 11, 77, 105),
                      boxShadow: const [
                        BoxShadow(
                            color: Color.fromARGB(255, 154, 164, 168),
                            offset: Offset(02, 03),
                            blurRadius: 0.5,
                            spreadRadius: 0.1),
                      ]),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HomeScreen()));
                      // if (formkey.currentState!.validate()) {
                      //   login();
                      // }
                    },
                    child: const Text("Sign In",
                        style: TextStyle(
                            fontSize: 17.0,
                            color: Color.fromARGB(255, 254, 255, 255)),
                        textAlign: TextAlign.center),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Text("Don't have an account?",
                          style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 11, 77, 105)),
                          textAlign: TextAlign.center),
                    ),
                    //       const SizedBox(
                    //   width: 40,
                    // ),
                    // Padding(
                    //   padding: EdgeInsets.only(left: 4),
                    //   child: Text("Sign up",
                    //       style: TextStyle(
                    //           fontSize: 17.0, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 192, 192, 192)),
                    //       textAlign: TextAlign.center),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
