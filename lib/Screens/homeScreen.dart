import 'package:flutter/material.dart';
import 'package:fyp/Screens/allDiseases.dart';
import 'package:fyp/Screens/allDoctors.dart';
import 'package:fyp/Screens/doctorDetail.dart';
import 'package:fyp/Screens/searchResult.dart';
import 'package:fyp/Screens/signIn.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> getDocs;
  String currentUsername = '';
  List<Map<String, dynamic>> doctors = [];
  final searchFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
    getDocs = fetchDoctorsList();
  }

  Future<List<Map<String, dynamic>>> fetchDoctorsList() async {
    try {
      QuerySnapshot doctorsData =
          await FirebaseFirestore.instance.collection('doctors').get();
      for (var item in doctorsData.docs) {
        var data = item.data() as Map<String, dynamic>;
        data['id'] = item.id;
        doctors.add(data);
      }
      return doctors;
    } catch (e) {
      print('Error getting doctors: $e');
      return [];
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      setState(() {
        currentUsername = userData['name'];
      });
    } catch (e) {
      print('Error getting user: $e');
    }
  }

  void logOut() async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const SignInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> row1 = [
      {
        'name': 'Dr. John Doe',
        'description': 'Cardiologist',
        'rating': 4.5,
        'icon': Icons.call,
        'timing': '9:00 AM - 5:00 PM',
        'availibility': 'Monday-Friday',
      },
      {
        'name': 'Emma Wilson',
        'description': 'ICU Nurse',
        'rating': 4.5,
        'icon': Icons.health_and_safety,
        'timing': '11:00 AM - 7:00 PM',
        'availibility': 'Monday-Friday',
      },
      {
        'name': 'Dr. Lilly Smith',
        'description': 'Pediatrician',
        'rating': 4.6,
        'icon': Icons.call,
        'timing': '10:00 AM - 6:00 PM',
        'availibility': 'Monday-Friday',
      },
      {
        'name': 'Dr. Alex John',
        'description': 'Orthopedic Surgeon',
        'rating': 4.2,
        'icon': Icons.call,
        'timing': '8:00 AM - 4:00 PM',
        'availibility': 'Monday-Friday',
      },
    ];
    final List<Map<String, dynamic>> row2 = [
      {
        'name': 'Dr. Lilly Smith',
        'description': 'Pediatrician',
        'rating': 4.7,
        'icon': Icons.local_hospital,
        'timing': '11:00 AM - 7:00 PM',
        'availibility': 'Monday-Friday',
        'experience': '6 years of experience',
      },
      {
        'name': 'Dr. Alex Johnson',
        'description': 'Neurosurgeon',
        'rating': 4.2,
        'icon': Icons.call,
        'timing': '8:00 AM - 4:00 PM',
        'availibility': 'Monday-Friday',
        'experience': '4 years of experience',
      },
      {
        'name': 'Emma Wilson',
        'description': 'Pediatric Nurse',
        'rating': 4.5,
        'icon': Icons.call,
        'timing': '9:00 AM - 5:00 PM',
        'availibility': 'Monday-Friday',
        'experience': '3 years of experience',
      },
      {
        'name': 'Jane Smith',
        'description': 'Gastroenterologist',
        'rating': 4.8,
        'icon': Icons.call,
        'timing': '10:00 AM - 6:00 PM',
        'availibility': 'Monday-Friday',
        'experience': '4 years of experience',
      },
    ];
    final List<Map<String, dynamic>> row3 = [
      {
        'name': 'Emma Wilson',
        'description': 'Pediatric Nurse',
        'rating': 4.5,
        'icon': Icons.call,
        'timing': '9:00 AM - 5:00 PM',
        'availibility': 'Monday-Friday',
        'experience': '3 years of experience',
      },
      {
        'name': 'Dr. Lilly Smith',
        'description': 'Pediatrician',
        'rating': 4.7,
        'icon': Icons.local_hospital,
        'timing': '11:00 AM - 7:00 PM',
        'availibility': 'Monday-Friday',
        'experience': '6 years of experience',
      },
      {
        'name': 'Dr. Alex Johnson',
        'description': 'Neurosurgeon',
        'rating': 4.2,
        'icon': Icons.call,
        'timing': '8:00 AM - 4:00 PM',
        'availibility': 'Monday-Friday',
        'experience': '4 years of experience',
      },
      {
        'name': 'Jane Smith',
        'description': 'Gastroenterologist',
        'rating': 4.8,
        'icon': Icons.call,
        'timing': '10:00 AM - 6:00 PM',
        'availibility': 'Monday-Friday',
        'experience': '4 years of experience',
      },
    ];
    var iconList = [
      'assets/images/Diseases/fever.png',
      'assets/images/Diseases/heart.png',
      'assets/images/Diseases/cancer.png',
      'assets/images/Diseases/diarrhea.png',
      'assets/images/Diseases/pragnancy.png',
      'assets/images/Diseases/hypertention.png',
    ];
    var iconList2 = [
      'assets/images/Diseases/dengue.png',
      'assets/images/Diseases/stomach.png',
      'assets/images/Diseases/kidneys.png',
      'assets/images/Diseases/piles.png',
      'assets/images/Diseases/lungs.png',
      'assets/images/Diseases/typhoid.png',
    ];
    var textList2 = [
      'Dengue fever',
      'Gastritis',
      'Kidney stone',
      'Piles',
      'Lungs cancer',
      'Typhoid fever',
    ];

    var imageList = [
      'assets/images/Doctors/MDryle.png',
      'assets/images/Doctors/FD3.png', //sofia
      'assets/images/Doctors/FD5.png', //lilly
      'assets/images/Doctors/MD2.png', //altas
      'assets/images/Doctors/MD1.png', //micheal
    ];
    var imageList2 = [
      'assets/images/Doctors/FD5.png',
      'assets/images/Doctors/MD2.png',
      'assets/images/Doctors/FD3.png',
      'assets/images/Doctors/MD1.png',
      'assets/images/Doctors/MDryle.png',
    ];
    var imageList3 = [
      'assets/images/Doctors/FD3.png',
      'assets/images/Doctors/FD5.png', //lilly
      'assets/images/Doctors/MD1.png',
      'assets/images/Doctors/MDryle.png',
      'assets/images/Doctors/MD2.png', //altas
    ];

    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 233, 242, 250),
        // color: const Color.fromARGB(255, 230, 239, 248),
        // color: const Color.fromARGB(255, 232, 243, 248),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: SizedBox(
                width: double.infinity,
                child: Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 120, // Adjust the height as needed
                        padding: const EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 231, 238, 241),
                          ),
                          color: const Color.fromARGB(255, 46, 77, 94),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color.fromARGB(255, 232, 243, 248),

                              // Color.fromARGB(255, 162, 207, 228),
                              Color.fromARGB(255, 17, 95, 131),
                              // Color.fromARGB(255, 67, 149, 187),

                              // Color.fromARGB(255, 67, 149, 187),
                              // Color.fromARGB(255, 3, 75, 109),
                              // Color.fromARGB(255, 146, 249, 254),
                              // Color.fromARGB(255, 146, 249, 254),
                              // Color.fromARGB(255, 195, 243, 242),
                              // Color.fromARGB(255, 214, 250, 255),

                              // Color.fromARGB(255, 146, 249, 254),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 185, 181, 181)
                                  .withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Container(
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                      radius: 27.0,
                                      backgroundImage: AssetImage(
                                          "assets/images/AppImages/applogo.png")),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: 17,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Emma Wilso',
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              color: Color.fromARGB(
                                                  255, 11, 77, 105),
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Find your suitable Doctor here',
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: Color.fromARGB(
                                                255, 252, 252, 253),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 18, right: 5),
                                  child: Icon(
                                    Icons.notifications_sharp,
                                    size: 30.0,

                                    color: Color.fromARGB(255, 252, 253, 253),
                                    // color: Color.fromARGB(255, 12, 89, 122),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -25,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search for a Doctor....',
                              hintStyle: const TextStyle(
                                  color: Color.fromARGB(255, 163, 163, 163)),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 16.0),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  if (searchFieldController.text.isNotEmpty) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SearchResultsScreen(
                                                    searchResult:
                                                        searchFieldController
                                                            .text)));
                                  }
                                },
                                child: const Icon(
                                  Icons.send,
                                  color: Color.fromARGB(255, 12, 89, 122),
                                ),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color.fromARGB(255, 12, 89, 122),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 35,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 165,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: row1.length, // Use your static data row1 here
                  itemBuilder: (context, index) {
                    final item = row1[index]; // Access static data from row1

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorDetailScreen(
                                  docId: item['id']!), // Use the static id here
                            ),
                          );
                        },
                        child: Container(
                          height: 160,
                          width: 255,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 7, 97, 137),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: CustomItem(
                                  name: item['name'] ?? '',
                                  description: item['description'] ?? '',
                                  rating: item['rating'] ?? 0.0,
                                  icon: Icons.call,
                                  timing: item['timing'] ?? '',
                                  availibility: item['availibility'] ?? '',
                                ),
                              ),
                              SizedBox(
                                height: 165,
                                width: 110,
                                child: Image.asset(
                                  imageList[
                                      index], // Ensure imageList is valid and has data
                                  fit: BoxFit.cover,
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
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color.fromARGB(255, 11, 77, 105),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AllDiseasesScreen()));
                    },
                    child: const Text(
                      'see all',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(255, 11, 77, 105),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: iconList2.length,
                itemBuilder: (context, index) {
                  final item = iconList2[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Image.asset(
                            iconList2[index],
                            height: 50,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          textList2[index],
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            // color: Color.fromARGB(255, 7, 97, 137),
                            // color: Color.fromARGB(255, 177, 27, 16),
                            color: Color.fromARGB(255, 122, 8, 8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Doctors',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 11, 77, 105),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AllSpecialistScreen()));
                    },
                    child: const Text(
                      'see all',
                      style: TextStyle(
                        color: Color.fromARGB(255, 11, 77, 105),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: row2.length,
                itemBuilder: (context, index) {
                  final item = row2[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      height: 140,
                      width: 230,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 212, 229, 243),
                        // color: const Color.fromARGB(255, 211, 232, 243),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 150,
                            width: 90,
                            child: Image.asset(
                              imageList2[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                          CustomItem2(
                            name: item['name'],
                            description: item['description'],
                            rating: item['rating'],
                            icon: item['icon'],
                            timing: item['timing'],
                            experinece: item["experience"],
                            // availibility: item["availibility"],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AllSpecialistScreen()));
                    },
                    child: const Text(
                      'Recommended Doctors',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 11, 77, 105),
                      ),
                    ),
                  ),
                  const Text(
                    'see all',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 11, 77, 105),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: row3.length,
                itemBuilder: (context, index) {
                  final item = row3[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      width: 130,
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 246, 250, 255),
                        // color: const Color.fromARGB(255, 252, 254, 255),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              imageList3[index],
                              fit: BoxFit.cover,
                            ),
                            CustomItem3(
                              name: item['name'],
                              description: item["description"],
                              rating: item["rating"],
                            )
                          ],
                        ),
                      )),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomItem extends StatelessWidget {
  final String name;
  final String description;
  final double rating;
  final IconData icon;
  final String timing;
  final String availibility;

  const CustomItem({
    super.key,
    required this.name,
    required this.description,
    required this.rating,
    required this.icon,
    required this.timing,
    required this.availibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(width: 10.0),
          Text(
            name,
            style: const TextStyle(
                fontSize: 15.0,
                color: Color.fromARGB(255, 255, 253, 253),
                fontWeight: FontWeight.bold),
          ),
          // const SizedBox(height: 5.0),
          Text(
            description,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(255, 255, 254, 254)),
          ),
          // const SizedBox(height: 5.0),
          Text(
            availibility,
            style: const TextStyle(
                fontSize: 12.0, color: Color.fromARGB(255, 255, 254, 254)),
          ),
          // const SizedBox(height: 5.0),
          Text(
            timing,
            style: const TextStyle(
                fontSize: 12.0, color: Color.fromARGB(255, 255, 254, 254)),
          ),
          // const SizedBox(height: 5.0),

          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.round() ? Icons.star : Icons.star_border,
                    size: 10.0,
                    color: Colors.yellow,
                  );
                }),
              ),
              const SizedBox(width: 5.0),
              Text(
                rating.toString(),
                style: const TextStyle(
                  fontSize: 10.0,
                  color: Color.fromARGB(255, 251, 252, 252),
                ),
              ),
            ],
          ),
          const Row(
            children: [
              Icon(
                Icons.call,
                size: 15,
                color: Colors.white,
              ),
              SizedBox(width: 5.0),
              Text(
                "Contact",
                style: TextStyle(
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic,
                    color: Color.fromARGB(255, 255, 254, 254)),
              ),
            ],
          ),
          const SizedBox(height: 7.0),
          Container(
              height: 25,
              width: 85,
              decoration: BoxDecoration(
                color: Colors.white,
                border:
                    Border.all(color: const Color.fromARGB(255, 226, 226, 226)),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Center(
                child: Text(
                  "Approach me",
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 12, 89, 122),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}

class CustomItem2 extends StatelessWidget {
  final String name;
  final String description;
  final double rating;
  final IconData icon;
  final String timing;
  final String experinece;
  // final String availibility;

  const CustomItem2({
    super.key,
    required this.name,
    required this.description,
    required this.rating,
    required this.icon,
    required this.timing,
    required this.experinece,
    // required this.availibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10.0),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.grey.withOpacity(0.5),
      //       spreadRadius: 2,
      //       blurRadius: 5,
      //       offset: const Offset(0, 3),
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 10.0),
          Text(
            name,
            style: const TextStyle(
                fontSize: 15.0,
                color: Color.fromARGB(255, 11, 77, 105),
                fontWeight: FontWeight.bold),
          ),

          Text(
            description,
            style: const TextStyle(
              fontSize: 13.0,
              color: Color.fromARGB(255, 109, 4, 4),
              // fontWeight: FontWeight.w800,
              // color: Color.fromARGB(255, 151, 15, 15),
            ),
          ),

          // Text(
          //   availibility,
          //   style: const TextStyle(
          //     fontSize: 10.0,
          //     color: Color.fromARGB(255, 11, 77, 105),
          //   ),
          // ),

          Text(
            timing,
            style: const TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 11, 77, 105),
            ),
          ),

          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.round() ? Icons.star : Icons.star_border,
                    size: 10.0,
                    color: const Color.fromARGB(255, 16, 54, 110),
                  );
                }),
              ),
              const SizedBox(width: 5.0),
              Text(
                rating.toString(),
                style: const TextStyle(
                  fontSize: 10.0,
                  color: Color.fromARGB(255, 11, 77, 105),
                ),
              ),
            ],
          ),
          Text(
            experinece,
            style: const TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Color.fromARGB(255, 11, 77, 105),
            ),
          ),
          const SizedBox(height: 5.0),
          GestureDetector(
            child: Container(
                height: 25,
                width: 73,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 12, 89, 122),
                  // border: Border.all(
                  //   color: const Color.fromARGB(255, 240, 237, 237),
                  // ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Center(
                  child: Text(
                    "Book now",
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      // color: Color.fromARGB(255, 12, 89, 122),
                    ),
                  ),
                )),
          )
        ],
      ),
    );
  }
}

class CustomItem3 extends StatelessWidget {
  final String name;
  final String description;
  final double rating;
  // final IconData icon;
  // final String timing;
  // final String experinece;
  // final String availibility;

  const CustomItem3({
    super.key,
    required this.name,
    required this.description,
    required this.rating,
    // required this.icon,
    // required this.timing,
    // required this.experinece,
    // required this.availibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0.0),
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10.0),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.grey.withOpacity(0.5),
      //       spreadRadius: 2,
      //       blurRadius: 5,
      //       offset: const Offset(0, 3),
      //     ),
      //   ],
      // ),
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(
                fontSize: 13.0,
                color: Color.fromARGB(255, 11, 77, 105),
                fontWeight: FontWeight.bold),
          ),

          Text(
            description,
            style: const TextStyle(
              color: Color.fromARGB(255, 109, 4, 4),
              fontSize: 12.0,
              //color: Color.fromARGB(255, 151, 15, 15),
              // color: Color.fromARGB(255, 11, 77, 105),
              // fontWeight: FontWeight.w800,
              // color: Color.fromARGB(255, 151, 15, 15),
            ),
          ),

          // Text(
          //   availibility,
          //   style: const TextStyle(
          //     fontSize: 10.0,
          //     color: Color.fromARGB(255, 11, 77, 105),
          //   ),
          // ),

          // Text(
          //   timing,
          //   style: const TextStyle(
          //     fontSize: 10.0,
          //     fontWeight: FontWeight.bold,
          //     color: Color.fromARGB(255, 11, 77, 105),
          //   ),
          // ),
          const SizedBox(
            height: 3,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: List.generate(1, (index) {
                  return Icon(
                    index < rating.round() ? Icons.star : Icons.star_border,
                    size: 11.0,
                    color: const Color.fromARGB(255, 16, 54, 110),
                  );
                }),
              ),
              const SizedBox(width: 5.0),
              Text(
                rating.toString(),
                style: const TextStyle(
                  fontSize: 11.0,
                  color: Color.fromARGB(255, 11, 77, 105),
                ),
              ),
            ],
          ),
          // Text(
          //   experinece,
          //   style: const TextStyle(
          //     fontSize: 11.0,
          //     fontWeight: FontWeight.bold,
          //     fontStyle: FontStyle.italic,
          //     color: Color.fromARGB(255, 11, 77, 105),
          //   ),
          // ),
        ],
      ),
    );
  }
}
