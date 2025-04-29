// // // ignore_for_file: non_constant_identifier_names

// // import 'package:flutter/material.dart';
// // import 'package:fyp/components/bigContainer.dart';
// // import 'package:fyp/screens/allDoctors.dart';

// // // ignore: camel_case_types, must_be_immutable
// // class allDiseases extends StatelessWidget {
// //   allDiseases({super.key});
// //   // ignore: unused_field
// //   final Set<String> _Diseases = {
// //     "Disease 1",
// //     'Disease 2',
// //     "Disease 3",
// //     "Disease 4",
// //     "Disease 5",
// //     "Disease 6",
// //   };
// //   var iconList2 = [
// //     "assets/images/typhoid.png",
// //     "assets/images/dengue.png",
// //     "assets/images/stomach.png",
// //     "assets/images/kidneys.png",
// //     "assets/images/piles.png",
// //     "assets/images/lungs.png",
// //   ];

// //   var textList2 = [
// //     "Typhoid fever",
// //     "dengue fever",
// //     "Gastritis",
// //     "Kidney stone",
// //     "Piles",
// //     "Lungs cancer"
// //   ];

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //         appBar: AppBar(
// //           backgroundColor: const Color.fromARGB(255, 57, 102, 150),
// //           title: const Text(
// //             "All Diseases",
// //             style: TextStyle(color: Colors.white, fontSize: 17),
// //           ),
// //         ),
// //         body: Padding(
// //           padding: const EdgeInsets.all(9.0),
// //           child: GridView.builder(
// //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                   crossAxisCount: 2,
// //                   mainAxisExtent: 175,
// //                   mainAxisSpacing: 8,
// //                   crossAxisSpacing: 8),
// //               itemCount: _Diseases.length,
// //               itemBuilder: (BuildContext context, int Index) {
// //                 return GestureDetector(
// //                   onTap: () {
// //                     Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                             builder: (context) => const allSpecialist()));
// //                   },
// //                   child: MyBcontainer(
// //                     child: Column(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         crossAxisAlignment: CrossAxisAlignment.center,
// //                         children: [
// //                           Padding(
// //                             padding: const EdgeInsets.all(9.0),
// //                             child: Image.asset(iconList2[Index]),
// //                           ),
// //                           const SizedBox(height: 3),
// //                           Text(
// //                             textList2[Index],
// //                             style: const TextStyle(
// //                               fontSize: 14,
// //                               color: Color.fromARGB(255, 254, 255, 255),
// //                             ),
// //                             textAlign: TextAlign.center,
// //                           ),
// //                         ]),
// //                   ),
// //                 );
// //               }),
// //         ));
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:fyp/components/bigContainer.dart';
// import 'package:fyp/screens/allDoctors.dart';

// class allDiseases extends StatelessWidget {
//   allDiseases({super.key});

//   final Set<String> _Diseases = {
//     "Disease 1",
//     'Disease 2',
//     "Disease 3",
//     "Disease 4",
//     "Disease 5",
//     "Disease 6",
//   };

//   var iconList2 = [
//     "assets/images/typhoid.png",
//     "assets/images/dengue.png",
//     "assets/images/stomach.png",
//     "assets/images/kidneys.png",
//     "assets/images/piles.png",
//     "assets/images/lungs.png",
//   ];

//   var textList2 = [
//     "Typhoid fever",
//     "Dengue fever",
//     "Gastritis",
//     "Kidney stone",
//     "Piles",
//     "Lungs cancer"
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 249, 253, 255),
//       appBar: AppBar(
//         backgroundColor: Color.fromARGB(255, 11, 77, 105),
//         title: const Text(
//           "All Diseases",
//           style: TextStyle(color: Colors.white, fontSize: 19),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0), // Add padding to ListView
//         child: ListView.builder(
//           itemCount: _Diseases.length,
//           itemBuilder: (BuildContext context, int index) {
//             return GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const allSpecialist()));
//               },
//               child: Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//                 color: Colors.white, // Set card color
//                 elevation: 5, // Adding a shadow for depth
//                 margin: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.all(10),
//                   leading: CircleAvatar(
//                     backgroundImage: AssetImage(iconList2[index]),
//                     radius: 30, // You can adjust the size of the icon
//                   ),
//                   title: Text(
//                     textList2[index],
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Color.fromARGB(255, 11, 77, 105),
//                     ),
//                   ),
//                   subtitle: const Text(
//                     "Tap to find related doctors & specialists",
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   trailing: const Icon(
//                     Icons.arrow_forward_ios,
//                     size: 18,
//                     color: Color.fromARGB(255, 11, 77, 105),
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
import 'package:fyp/Screens/allDoctors.dart';

class AllDiseasesScreen extends StatefulWidget {
  const AllDiseasesScreen({super.key});

  @override
  State<AllDiseasesScreen> createState() => _AllDiseasesScreenState();
}

class _AllDiseasesScreenState extends State<AllDiseasesScreen> {
  final Set<String> _diseases = {
    "Disease 1",
    'Disease 2',
    "Disease 3",
    "Disease 4",
    "Disease 5",
    "Disease 6",
  };

  var iconList2 = [
    "assets/images/Diseases/typhoid.png",
    "assets/images/Diseases/dengue.png",
    "assets/images/Diseases/stomach.png",
    "assets/images/Diseases/kidneys.png",
    "assets/images/Diseases/piles.png",
    "assets/images/Diseases/lungs.png",
  ];

  var textList2 = [
    "Typhoid fever",
    "Dengue fever",
    "Gastritis",
    "Kidney stone",
    "Piles",
    "Lungs cancer"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 253, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 11, 77, 105),
        title: const Text(
          "All Diseases",
          style: TextStyle(color: Colors.white, fontSize: 19),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0), // Add padding to ListView
        child: ListView.builder(
          itemCount: _diseases.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AllSpecialistScreen()));
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                color: index.isEven
                    ? const Color.fromARGB(255, 233, 242, 250)
                    : const Color.fromARGB(
                        246, 239, 250, 238), // Add alternating colors
                elevation: 6, // Adding a stronger shadow for depth
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(iconList2[index]),
                    radius: 30, // You can adjust the size of the icon
                    backgroundColor: Colors.white,
                  ),
                  title: Text(
                    textList2[index],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 11, 77, 105),
                    ),
                  ),
                  subtitle: const Text(
                    "Tap to find related doctors & specialists",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Color.fromARGB(255, 109, 4, 4),
                    // color: Color.fromARGB(255, 11, 77, 105),
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
