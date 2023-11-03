import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmeringTextListWidget extends StatelessWidget {
  final double width;
  final int numOfLines;
  ShimmeringTextListWidget({required this.width, required this.numOfLines});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        numOfLines, // Number of lines of text
        (index) {
          return Shimmer.fromColors(
            baseColor: Color.fromARGB(255, 224, 224, 224),
            highlightColor: Color.fromARGB(255, 245, 245, 245),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 5.0),
                color: Colors.white,
                width: width, // Set the desired width
                height: 15, // Set the desired height
              ),
            ),
          );
        },
      ),
    );
  }
}
