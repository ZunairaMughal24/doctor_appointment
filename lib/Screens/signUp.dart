// ignore_for_file: unused_element

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:fyp/Screens/docSignUp.dart';
import 'package:fyp/Screens/homeScreen.dart';


// ignore: camel_case_types
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

// ignore: camel_case_types
class _SignUpScreenState extends State<SignUpScreen> {
  var formkey = GlobalKey<FormState>();
  var isvalid = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // ignore: unused_field
  final TextEditingController _rPasswordController = TextEditingController();

 
  void createAccount() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String cPassword = _rPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      log("Please fill all the details!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all the details!")),
      );
    } else if (password != cPassword) {
      log("Passwords do not match!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match!")),
      );
    } else {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // Store user details in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': name,
          'email': email,
        });

        if (userCredential.user != null) {
          if (!mounted) return;

          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = "This email address is already in use.";
            break;
          case 'invalid-email':
            errorMessage = "The email address is not valid.";
            break;
          case 'operation-not-allowed':
            errorMessage =
                "This operation is not allowed. Please contact support.";
            break;
          case 'weak-password':
            errorMessage = "The password provided is too weak.";
            break;
          default:
            errorMessage = "An error occurred. Please try again.";
        }
        log(errorMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        log("An unexpected error occurred: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("An unexpected error occurred. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,

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
                // Color.fromARGB(255, 7, 97, 137),
              ]),
        ),

        // ignore: prefer_const_constructors  Color.fromARGB(255, 254, 255, 255),

        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: ListView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              children: [
                // ignore: sized_box_for_whitespace
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.37,
                  child: Image.asset(
                    "assets/images/AppImages/signUp.png",
                    alignment: Alignment.topCenter,
                  ),
                ),
                // SizedBox(
                //   height: screenHeight * 0.01,
                // ),
                const Padding(
                  padding: EdgeInsets.only(left: 28),
                  child: Text(
                    "Create Account",
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
                    "Please enter your name, email and   password to create account",
                    style: TextStyle(
                      fontSize: 15,
                      // fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 152, 158, 161),
                    ),
                    // textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Form(
                  key: formkey,
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              // ignore: sort_child_properties_last
                              child: TextFormField(
                                controller: _nameController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "enter your name";
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Name',
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
                              height: screenHeight * 0.06,
                              width: screenWidth * 0.88,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 238, 235, 235),
                                      width: 1.0),
                                  borderRadius: BorderRadius.circular(16),
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  boxShadow: const [
                                    BoxShadow(
                                        color:
                                            Color.fromARGB(255, 221, 218, 218),
                                        offset: Offset(02, 03),
                                        blurRadius: 0.5,
                                        spreadRadius: 0.1),
                                  ]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9),
                            child: Container(
                              // ignore: sort_child_properties_last
                              child: TextFormField(
                                controller: _emailController,
                                onChanged: (value) {
                                  if (value.contains("@gmail.com")) {
                                    setState(() {
                                      isvalid = true;
                                    });
                                  } else {
                                    setState(() {
                                      isvalid = false;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "enter your email";
                                  }
                                  return null;
                                },
                                obscureText: false,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Email',
                                  hintStyle: TextStyle(
                                    fontSize: 17.0,
                                    color: Color.fromARGB(255, 11, 77, 105),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: Color.fromARGB(255, 11, 77, 105),
                                  ),
                                ),
                              ),

                              height: screenHeight * 0.06,
                              width: screenWidth * 0.88,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 238, 235, 235),
                                      width: 1.0),
                                  borderRadius: BorderRadius.circular(16),
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  boxShadow: const [
                                    BoxShadow(
                                        color:
                                            Color.fromARGB(255, 221, 218, 218),
                                        offset: Offset(02, 03),
                                        blurRadius: 0.5,
                                        spreadRadius: 0.1),
                                  ]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9),
                            child: Container(
                              // ignore: sort_child_properties_last

                              // ignore: sort_child_properties_last
                              child: TextFormField(
                                controller: _passwordController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "enter your password";
                                  }
                                  return null;
                                },
                                obscureText: false,
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

                              height: screenHeight * 0.06,
                              width: screenWidth * 0.88,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 238, 235, 235),
                                      width: 1.0),
                                  borderRadius: BorderRadius.circular(16),
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  boxShadow: const [
                                    BoxShadow(
                                        color:
                                            Color.fromARGB(255, 221, 218, 218),
                                        offset: Offset(02, 03),
                                        blurRadius: 0.5,
                                        spreadRadius: 0.1),
                                  ]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9),
                            child: Container(
                              // ignore: sort_child_properties_last

                              // ignore: sort_child_properties_last
                              child: TextFormField(
                                controller: _rPasswordController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "re-type the password";
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Confirm password',
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
                              height: screenHeight * 0.06,
                              width: screenWidth * 0.88,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 238, 235, 235),
                                      width: 1.0),
                                  borderRadius: BorderRadius.circular(16),
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  boxShadow: const [
                                    BoxShadow(
                                        color:
                                            Color.fromARGB(255, 221, 218, 218),
                                        offset: Offset(02, 03),
                                        blurRadius: 0.5,
                                        spreadRadius: 0.1),
                                  ]),
                            ),
                          ),
                        ]),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.035,
                ),
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
                    // child: TextButton(
                    //   onPressed: () {
                    //     if (formkey.currentState!.validate()) {
                    //       createAccount(_nameController.text.trim(), _passwordController.text.trim());
                    //     }
                    //   },
                    child: TextButton(
                      onPressed: () {
                        if (formkey.currentState!.validate()) {
                          createAccount();
                        }
                      },
                      child: const Text("Sign up",
                          style: TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 254, 255, 255)),
                          textAlign: TextAlign.center),
                    ),
                  ),
                ),
                // SizedBox(
                //   height: screenHeight * 0.01,
                // ),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                //   child: Container(
                //     height: screenHeight * 0.06,
                //     width: screenWidth * 0.88,
                //     decoration: BoxDecoration(
                //         border: Border.all(color: const Color.fromARGB(255, 165, 180, 184), width: 1.0),
                //         borderRadius: BorderRadius.circular(16),
                //         color: const Color.fromARGB(255, 11, 77, 105),
                //         boxShadow: const [
                //           BoxShadow(
                //               color: Color.fromARGB(255, 165, 180, 184),
                //               offset: Offset(02, 03),
                //               blurRadius: 0.5,
                //               spreadRadius: 0.1),
                //         ]),
                //     child: TextButton(
                //       onPressed: () {
                //         Navigator.push(context, MaterialPageRoute(builder: (context) => const DocSignUp()));
                //       },
                //       child: const Text("Sign up as Doctor",
                //           style: TextStyle(fontSize: 17.0, color: Color.fromARGB(255, 254, 255, 255)),
                //           textAlign: TextAlign.center),
                //     ),
                //   ),
                // ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DoctorSignUpScreen()));
                  },
                  child: const Text("Already have an account?",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 3, 76, 110)),
                      textAlign: TextAlign.center),
                ),

                // children
              ]),
        ),
      ),
    );
  }
}
