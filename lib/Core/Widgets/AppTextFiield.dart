import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?)? validator;

  const AppTextField.Regular({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(top: screenHeight * 0.015),
      child: Container(
        height: screenHeight * 0.06,
        width: screenWidth * 0.88,
        decoration: BoxDecoration(
          border: Border.all(
              color: const Color.fromARGB(255, 238, 235, 235), width: 1.0),
          borderRadius: BorderRadius.circular(16),
          color: const Color.fromARGB(255, 255, 255, 255),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 221, 218, 218),
              offset: Offset(2, 3),
              blurRadius: 0.5,
              spreadRadius: 0.1,
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 11, 77, 105),
            ),
            prefixIcon: Icon(
              icon,
              color: const Color.fromARGB(255, 11, 77, 105),
            ),
          ),
        ),
      ),
    );
  }
}
