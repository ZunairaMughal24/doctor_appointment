// import 'package:flutter/material.dart';

// import 'package:fyp/screens/myAppointments.dart';

// class DescriptionScr extends StatefulWidget {
//   const DescriptionScr({super.key});

//   @override
//   State<DescriptionScr> createState() => _DescriptionScrState();
// }

// class _DescriptionScrState extends State<DescriptionScr> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: const Color.fromARGB(255, 233, 241, 248),
//       backgroundColor: const Color.fromARGB(255, 247, 249, 252),
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 11, 77, 105),
//         title: const Text(
//           'Description',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.only(top: 30),
//         child: ListView(physics: const BouncingScrollPhysics(), children: [
//           const Padding(
//             padding: EdgeInsets.only(left: 15, top: 5),
//             child: Text(
//               "Give us an insight into your background, experience, and professional strengths.",
//               style: TextStyle(
//                   fontStyle: FontStyle.italic,
//                   color: Color.fromARGB(255, 146, 24, 24),
//                   // color: Color.fromARGB(255, 11, 77, 105),
//                   fontSize: 17,
//                   fontWeight: FontWeight.bold),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(14),
//             child: Container(
//               height: 450,
//               width: 320,
//               decoration: BoxDecoration(
//                   border: Border.all(
//                       color: const Color.fromARGB(255, 228, 227, 227),
//                       width: 1.0),
//                   borderRadius: BorderRadius.circular(17),
//                   color: const Color.fromARGB(255, 251, 253, 255),
//                   boxShadow: const [
//                     BoxShadow(
//                         color: Color.fromARGB(255, 201, 201, 201),
//                         offset: Offset(01, 03),
//                         blurRadius: 0.5,
//                         spreadRadius: 0.2),
//                   ]),
//               child: const Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: TextField(
//                   decoration: InputDecoration(
//                     border: InputBorder.none,
//                     hintText: "Add here...",
//                     hintStyle: TextStyle(
//                         fontSize: 16,
//                         color: Color.fromARGB(255, 149, 160, 165)),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 30,
//           ),
//           Padding(
//             padding: const EdgeInsets.all(14.0),
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const myAppSc(isUser: true)),
//                 );
//               },
//               child: Container(
//                 height: 55,
//                 width: 340,
//                 decoration: BoxDecoration(
//                     border: Border.all(
//                         color: Color.fromARGB(255, 201, 201, 201), width: 1.0),
//                     borderRadius: BorderRadius.circular(20),
//                     color: const Color.fromARGB(255, 11, 77, 105),
//                     boxShadow: const [
//                       BoxShadow(
//                           color: Color.fromARGB(255, 201, 201, 201),
//                           offset: Offset(01, 03),
//                           blurRadius: 0.5,
//                           spreadRadius: 0.2),
//                     ]),
//                 child: const Padding(
//                   padding: EdgeInsets.all(15.0),
//                   child: Text(
//                     "Submit",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 17,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:fyp/Screens/appointmentDetail.dart';
import 'package:fyp/Screens/myAppointments.dart';



class EditDescriptionScreen extends StatefulWidget {
  const EditDescriptionScreen({super.key});

  @override
  State<EditDescriptionScreen> createState() => _EditDescriptionScreenState();
}

class _EditDescriptionScreenState extends State<EditDescriptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 250, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 11, 77, 105),
        title: const Text(
          'Description',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 20),
            const Text(
              "Tell us about yourself",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color.fromARGB(255, 11, 77, 105),
              ),
              // textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Share your story, experience, and specialties. "
              "This helps us get to know you better!",
              style: TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 126, 17, 17),
                // color: Color.fromARGB(255, 80, 80, 80),
              ),
              // textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              height: 240,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color.fromARGB(255, 220, 220, 220),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  labelText: "Add here...",
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 149, 160, 165),
                    fontSize: 17,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyAppointmentsScreen(isUser: true)),
                );
              },
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 11, 77, 105),
                      Color.fromARGB(255, 30, 101, 130),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
