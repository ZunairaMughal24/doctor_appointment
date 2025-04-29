import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/Screens/appointmentDetail.dart';
import 'package:fyp/Screens/myAppointments.dart';
import 'package:fyp/Screens/schedualAppointments.dart';



import 'package:url_launcher/url_launcher.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String docId;
  const DoctorDetailScreen({super.key, required this.docId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 249, 252),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 11, 77, 105),
        title: const Text(
          'Dr. Detail',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('doctors')
            .doc(widget.docId)
            .get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var data = snapshot.data;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      height: 110,
                      width: 340,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(255, 228, 227, 227),
                              width: 1.0),
                          borderRadius: BorderRadius.circular(19),
                          color: const Color.fromARGB(255, 254, 254, 255),
                          boxShadow: const [
                            BoxShadow(
                                color: Color.fromARGB(255, 201, 201, 201),
                                offset: Offset(02, 03),
                                blurRadius: 0.5,
                                spreadRadius: 0.2),
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                                radius: 42,
                                backgroundColor:
                                    const Color.fromARGB(255, 11, 77, 105),
                                child: Image.asset(
                                  "assets/images/MD2RYLE.png",
                                )),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data!['name'] ?? "",
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 11, 77, 105),
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    data['speciality'] ?? "",
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 151, 9, 9),
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "${data['experience']} of experience",
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 11, 77, 105),
                                      fontStyle: FontStyle.italic,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        width: 340,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color.fromARGB(255, 228, 227, 227),
                                width: 1.0),
                            borderRadius: BorderRadius.circular(19),
                            color: const Color.fromARGB(255, 255, 255, 255),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color.fromARGB(255, 201, 201, 201),
                                  offset: Offset(02, 03),
                                  blurRadius: 0.5,
                                  spreadRadius: 0.2),
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Contact Number",
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 11, 77, 105),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          data['number'],
                                          style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 161, 165, 170),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                        height: 55,
                                        width: 55,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: const Color.fromARGB(
                                                    255, 11, 77, 105),
                                                width: 1.0),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color: const Color.fromARGB(
                                                255, 11, 77, 105),
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Color.fromARGB(
                                                      255, 181, 185, 187),
                                                  offset: Offset(02, 03),
                                                  blurRadius: 0.5,
                                                  spreadRadius: 0.1),
                                            ]),
                                        child: IconButton(
                                          onPressed: () async {
                                            var phone = Uri.parse(
                                                'tel:${data['number']}');
                                            await launchUrl(phone);
                                          },
                                          icon: const Icon(Icons.call,
                                              color: Colors.white),
                                          iconSize: 30,
                                        ))
                                  ]),
                              const SizedBox(height: 2),
                              const Text(
                                "Description",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 11, 77, 105),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "Dr. Ryle is renowned for their unparalleled expertise as a neurosurgeon. With the most steady hands in the entire medical community, Dr. Ryle is known for their exceptional skill and precision in performing intricate neurosurgical procedures. Patients travel from far and wide seeking Dr. Ryle's expertise, confident in their ability to deliver optimal outcomes even in the most challenging cases.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 161, 165, 170),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const IconButton(
                                  alignment: Alignment.centerLeft,
                                  onPressed: null,
                                  icon: Icon(
                                    Icons.location_on,
                                    color: Color.fromARGB(255, 11, 77, 105),
                                  )),
                              Text(
                                data['location'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  // fontStyle: FontStyle.italic,
                                  color: Color.fromARGB(255, 134, 6, 6),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Availability",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 11, 77, 105),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                data['availability'],
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 161, 165, 170),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Services",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 11, 77, 105),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                data['services'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 161, 165, 170),
                                ),
                              ),
                              const SizedBox(height: 19),
                              GestureDetector(
                                onTap: () {
                                  log("DOC DATA IS::: $data['name]");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SchedualApoointmentScreen(
                                              docId: widget.docId,
                                              name: data['name'],
                                            )),
                                  );
                                },
                                child: Container(
                                  height: 55,
                                  width: 340,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 11, 77, 105),
                                          width: 1.0),
                                      borderRadius: BorderRadius.circular(16),
                                      color: const Color.fromARGB(
                                          255, 11, 77, 105),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Color.fromARGB(
                                                255, 181, 185, 187),
                                            offset: Offset(02, 03),
                                            blurRadius: 0.5,
                                            spreadRadius: 0.1),
                                      ]),
                                  child: const Padding(
                                    padding: EdgeInsets.all(15.0),
                                    child: Text(
                                      "Make an Appointment",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
