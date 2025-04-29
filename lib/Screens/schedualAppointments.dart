import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/Screens/myAppointments.dart';


class SchedualApoointmentScreen extends StatefulWidget {
  final String docId, name;

  const SchedualApoointmentScreen({super.key, required this.docId, required this.name});

  @override
  State<SchedualApoointmentScreen> createState() => _SchedualApoointmentScreenState();
}

class _SchedualApoointmentScreenState extends State<SchedualApoointmentScreen> {
  var isLoading = false;
  var appointmentDayController = TextEditingController();
  var appointmentDateController = TextEditingController();
  var nameController = TextEditingController();
  var numberController = TextEditingController();

  makeAppointment() async {
    setState(() {
      isLoading = true;
    });
    var appointment =
        FirebaseFirestore.instance.collection('appointments').doc();
    await appointment.set({
      'appointment_day': appointmentDayController.text,
      'appointment_date': appointmentDateController.text,
      'appointment_by_name': nameController.text,
      'appointment_by_number': numberController.text,
      'appointment_by_id': FirebaseAuth.instance.currentUser!.uid,
      'appintment_with_id': widget.docId,
      'appointment_with_name': widget.name,
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 253, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 11, 77, 105),
        title: Text(
          widget.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 232, 243, 248),
        // color: const Color.fromARGB(255, 243, 250, 253),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
          child: ListView(physics: const BouncingScrollPhysics(), children: [
            const Padding(
              padding: EdgeInsets.only(left: 15, top: 5),
              child: Text(
                "Name",
                style: TextStyle(
                  color: Color.fromARGB(255, 11, 77, 105),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                width: 340,
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter your full name",
                      hintStyle: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 149, 160, 165)),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, top: 5),
              child: Text(
                "Contact number",
                style: TextStyle(
                  color: Color.fromARGB(255, 11, 77, 105),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                width: 340,
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: TextField(
                    controller: numberController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter number",
                      hintStyle: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 149, 160, 165)),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, top: 0),
              child: Text(
                "Select Appointment day",
                style: TextStyle(
                  color: Color.fromARGB(255, 11, 77, 105),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                height: 50,
                width: 320,
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: TextField(
                    controller: appointmentDayController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Select day",
                      hintStyle: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 149, 160, 165)),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, top: 5),
              child: Text(
                "Select Appointment date",
                style: TextStyle(
                  color: Color.fromARGB(255, 11, 77, 105),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                width: 340,
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: TextField(
                    controller: appointmentDateController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Select date",
                      hintStyle: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 149, 160, 165)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () async {
                        await makeAppointment();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MyAppointmentsScreen(isUser: true)),
                        );
                      },
                      child: Container(
                        height: 53,
                        width: 340,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color.fromARGB(255, 11, 77, 105),
                                width: 1.0),
                            borderRadius: BorderRadius.circular(16),
                            color: const Color.fromARGB(255, 11, 77, 105),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color.fromARGB(255, 181, 185, 187),
                                  offset: Offset(02, 03),
                                  blurRadius: 0.5,
                                  spreadRadius: 0.1),
                            ]),
                        child: const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Text(
                            "Submit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
          ]),
        ),
      ),
    );
  }
}
