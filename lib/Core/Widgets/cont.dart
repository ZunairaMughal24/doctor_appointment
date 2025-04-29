// import 'package:flutter/material.dart';

// class MyContainer extends StatelessWidget {
//   const MyContainer({super.key, required this.child});
//   final child;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
 
//       child: child,
//       height: 60,
//       width: 60,
//       decoration: BoxDecoration(
//           border: Border.all(color: const Color.fromARGB(255, 228, 227, 227), width: 1.0),
//           borderRadius: BorderRadius.circular(19),
//           color: const Color.fromARGB(255, 57, 102, 150),
//           boxShadow: const [
//             BoxShadow(
//                 color: Color.fromARGB(255, 201, 201, 201), offset: Offset(02, 03), blurRadius: 0.5, spreadRadius: 0.2),
//           ]),
//     );
//   }
// }
import 'package:flutter/material.dart';

class AppContainer extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget? child;
  final String? text;
  final Color? color;
  final BoxDecoration? decoration;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;

  const AppContainer({
    Key? key,
    this.height,
    this.width,
    this.child,
    this.text,
    this.color,
    this.decoration,
    this.borderRadius,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: decoration ??
          BoxDecoration(
            color: color ?? Colors.white,
            borderRadius: borderRadius ?? BorderRadius.circular(20),
            border: border ??
                Border.all(
                  color: const Color.fromARGB(255, 247, 247, 246),
                  width: 1.0,
                ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 194, 193, 193),
                offset: Offset(1, 3),
                blurRadius: 6,
                spreadRadius: 0.1,
              ),
            ],
          ),
      child: child,
    );
  }
}
