// import 'package:flutter/material.dart';
// import 'package:fyp/screens/doctorDetail.dart';

// // Replace this with your actual widget for your "allSpecialist" screen
// class allSpecialist extends StatelessWidget {
//   const allSpecialist({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Dummy data for doctors
//     var doctors = [
//       {
//         'name': 'Dr. Ryle',
//         'specialty': 'Cardiologist',
//         'experience': '10 years',
//         'image': 'assets/images/MD2RYLE.png'
//       },
//       {
//         'name': 'Dr. Sofia',
//         'specialty': 'Dermatologist',
//         'experience': '8 years',
//         'image': 'assets/images/FD3.png'
//       },
//       {
//         'name': 'Dr. Lilly',
//         'specialty': 'Pediatrician',
//         'experience': '5 years',
//         'image': 'assets/images/FD5.png'
//       },
//       {
//         'name': 'Dr. Altas',
//         'specialty': 'Orthopedist',
//         'experience': '15 years',
//         'image': 'assets/images/MD3.png'
//       },
//       {
//         'name': 'Dr. Michal',
//         'specialty': 'Surgeon',
//         'experience': '20 years',
//         'image': 'assets/images/MD1.png'
//       },
//     ];

//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 249, 253, 255),
//       appBar: AppBar(
//         backgroundColor: Color.fromARGB(255, 11, 77, 105),
//         title: const Text(
//           "All Specialist",
//           style: TextStyle(color: Colors.white, fontSize: 17),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView.builder(
//           itemCount: doctors.length,
//           itemBuilder: (context, index) {
//             var doctor = doctors[index];
//             return GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => DetailScr(
//                       docId: doctor[
//                           'name']!, // You can pass other data too like ID
//                     ),
//                   ),
//                 );
//               },
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 16.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black26,
//                         blurRadius: 4,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       // Doctor Image
//                       Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.asset(
//                             doctor['image']!,
//                             width: 100,
//                             height: 100,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       // Doctor Info
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 10.0, horizontal: 8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 doctor['name']!,
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color.fromARGB(255, 11, 77, 105),
//                                 ),
//                               ),
//                               const SizedBox(height: 5),
//                               Text(
//                                 "${doctor['specialty']}",
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Color.fromARGB(255, 109, 4, 4),
//                                 ),
//                               ),
//                               const SizedBox(height: 5),
//                               Text(
//                                 '${doctor['experience']} of Experience',
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Color.fromARGB(255, 123, 123, 123),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       // Right Arrow Icon for navigation
//                       Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: Icon(
//                           Icons.arrow_forward_ios,
//                           size: 16,
//                           color: Color.fromARGB(255, 11, 77, 105),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:fyp/screens/doctorDetail.dart';

// class allSpecialist extends StatelessWidget {
//   const allSpecialist({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Dummy data for doctors
//     var doctors = [
//       {
//         'name': 'Dr. Ryle',
//         'specialty': 'Cardiologist',
//         'experience': '10 years',
//         'rating': 4.5,
//         'image': 'assets/images/MD2RYLE.png',
//         'hospital': 'Heart Clinic',
//         'availability': 'Mon-Fri: 9 AM - 5 PM',
//         'color': const Color(0xFFFFF3E0), // Light Orange
//       },
//       {
//         'name': 'Dr. Sofia',
//         'specialty': 'Dermatologist',
//         'experience': '8 years',
//         'rating': 4.8,
//         'image': 'assets/images/FD3.png',
//         'hospital': 'Skin Care Center',
//         'availability': 'Tue-Sat: 10 AM - 4 PM',
//         'color': const Color(0xFFF1F8E9), // Light Green
//       },
//       {
//         'name': 'Dr. Lilly',
//         'specialty': 'Pediatrician',
//         'experience': '5 years',
//         'rating': 4.2,
//         'image': 'assets/images/FD5.png',
//         'hospital': 'Children’s Clinic',
//         'availability': 'Mon-Sun: 8 AM - 6 PM',
//         'color': const Color(0xFFE3F2FD), // Light Blue
//       },
//       {
//         'name': 'Dr. Altas',
//         'specialty': 'Orthopedist',
//         'experience': '15 years',
//         'rating': 4.7,
//         'image': 'assets/images/MD3.png',
//         'hospital': 'Bone Care Hospital',
//         'availability': 'Mon-Fri: 8 AM - 4 PM',
//         'color': const Color(0xFFFCE4EC), // Light Pink
//       },
//       {
//         'name': 'Dr. Michal',
//         'specialty': 'Surgeon',
//         'experience': '20 years',
//         'rating': 4.9,
//         'image': 'assets/images/MD1.png',
//         'hospital': 'Surgical Center',
//         'availability': 'Mon-Sat: 9 AM - 6 PM',
//         'color': const Color(0xFFFFF9C4), // Light Yellow
//       },
//     ];

//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 249, 253, 255),
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 11, 77, 105),
//         title: const Text(
//           "All Specialist",
//           style: TextStyle(color: Colors.white, fontSize: 19),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView.builder(
//           itemCount: doctors.length,
//           itemBuilder: (context, index) {
//             var doctor = doctors[index];
//             return GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => DetailScr(
//                       docId: doctor['name'] as String,
//                     ),
//                   ),
//                 );
//               },
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 12.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: doctor['color'] as Color,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 3,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       // Doctor Image
//                       Padding(
//                         padding: const EdgeInsets.all(0.0),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.asset(
//                             doctor['image'] as String,
//                             width: 90,
//                             height: 90,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       // Doctor Info
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 10.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 doctor['name'] as String,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color.fromARGB(255, 11, 77, 105),
//                                 ),
//                               ),
//                               Text(
//                                 doctor['specialty'] as String,
//                                 style: const TextStyle(
//                                   fontSize: 13,
//                                   color: Color.fromARGB(255, 109, 4, 4),
//                                 ),
//                               ),
//                               Text(
//                                 '${doctor['experience']} of Experience',
//                                 style: const TextStyle(
//                                   fontSize: 13,
//                                   color: Color.fromARGB(255, 123, 123, 123),
//                                 ),
//                               ),
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.star,
//                                     color: Colors.amber,
//                                     size: 16,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     '${doctor['rating']}',
//                                     style: const TextStyle(
//                                       fontSize: 13,
//                                       color: Color.fromARGB(255, 11, 77, 105),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 'Hospital: ${doctor['hospital']}',
//                                 style: const TextStyle(
//                                   fontSize: 13,
//                                   color: Color.fromARGB(255, 11, 77, 105),
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 '${doctor['availability']}',
//                                 style: const TextStyle(
//                                   fontSize: 13,
//                                   color: Color.fromARGB(255, 11, 77, 105),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       // Right Arrow Icon for navigation
//                       Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: const Icon(
//                           Icons.arrow_forward_ios,
//                           size: 16,
//                           color: Color.fromARGB(255, 11, 77, 105),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:fyp/Screens/doctorDetail.dart';



class AllSpecialistScreen extends StatelessWidget {
  const AllSpecialistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for doctors
    var doctors = [
      {
        'name': 'Dr. Ryle',
        'specialty': 'Cardiologist',
        'experience': '10 years',
        'rating': 4.5,
        'image': 'assets/images/Doctors/MDryle.png',
        'hospital': 'Heart Clinic',
        'availability': 'Mon-Fri: 9 AM - 5 PM',
        'tileColor': const Color.fromARGB(255, 248, 238, 238), // Light peach
      },
      {
        'name': 'Dr. Sofia',
        'specialty': 'Dermatologist',
        'experience': '8 years',
        'rating': 4.8,
        'image': 'assets/images/Doctors/FD3.png',
        'hospital': 'Skin Care Center',
        'availability': 'Tue-Sat: 10 AM - 4 PM',
        'tileColor': const Color.fromARGB(255, 243, 253, 244), // Light green
      },
      {
        'name': 'Dr. Lilly',
        'specialty': 'Pediatrician',
        'experience': '5 years',
        'rating': 4.2,
        'image': 'assets/images/Doctors/FD5.png',
        'hospital': 'Children’s Clinic',
        'availability': 'Mon-Sun: 8 AM - 6 PM',
        'tileColor': const Color.fromARGB(255, 237, 247, 255), // Light blue
      },
      {
        'name': 'Dr. Altas',
        'specialty': 'Orthopedist',
        'experience': '15 years',
        'rating': 4.7,
        'image': 'assets/images/Doctors/MD2.png',
        'hospital': 'Bone Care Hospital',
        'availability': 'Mon-Fri: 8 AM - 4 PM',
        'tileColor': const Color.fromARGB(255, 247, 241, 248), // Light purple
      },
      {
        'name': 'Dr. Michal',
        'specialty': 'Surgeon',
        'experience': '20 years',
        'rating': 4.9,
        'image': 'assets/images/Doctors/MD1.png',
        'hospital': 'Surgical Center',
        'availability': 'Mon-Sat: 9 AM - 6 PM',
        'tileColor': const Color.fromARGB(255, 248, 247, 236), // Light yellow
      },
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 253, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 11, 77, 105),
        title: const Text(
          "All Specialist",
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            var doctor = doctors[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorDetailScreen(
                        docId: doctor['name'] as String,
                        ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: doctor['tileColor'] as Color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Doctor Image
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 8, top: 6, bottom: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            doctor['image'] as String,
                            width: 80,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Doctor Info
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor['name'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 11, 77, 105),
                                ),
                              ),
                              Text(
                                doctor['specialty'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 109, 4, 4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${doctor['experience']} of Experience',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 123, 123, 123),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${doctor['rating']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 11, 77, 105),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Hospital: ${doctor['hospital']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 11, 77, 105),
                                ),
                              ),
                              Text(
                                '${doctor['availability']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 11, 77, 105),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Right Arrow Icon for navigation
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Color.fromARGB(255, 11, 77, 105),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
