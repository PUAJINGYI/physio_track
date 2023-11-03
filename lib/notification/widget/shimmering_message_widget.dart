import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmeringMessageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Color.fromARGB(255, 224, 224, 224),    // Color of the shimmer animation when not active
      highlightColor: Color.fromARGB(255, 245, 245, 245), // Color of the shimmer animation when active
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          width: 200, // Set the desired width
          height: 15, // Set the desired height
          color: Colors.white, // Background color behind the shimmer
        ),
      ),
    );
  }
}
