import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmeringMessageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Color.fromARGB(255, 224, 224, 224),    
      highlightColor: Color.fromARGB(255, 245, 245, 245),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          width: 200, 
          height: 15, 
          color: Colors.white, 
        ),
      ),
    );
  }
}
