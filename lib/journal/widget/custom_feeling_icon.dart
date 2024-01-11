import 'package:flutter/material.dart';

class CustomFeelingIcon extends StatelessWidget {
  final String feeling;
  final bool isSelected;

  const CustomFeelingIcon({
    required this.feeling,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      getFeelingIconData(feeling),
      color: isSelected ? Colors.blue : Colors.grey,
      size: 40.0,
    );
  }

  IconData getFeelingIconData(String feeling) {
    switch (feeling) {
      case 'Depressed':
        return Icons.mood_bad;
      case 'Sad':
        return Icons.sentiment_dissatisfied;
      case 'Neutral':
        return Icons.sentiment_neutral;
      case 'Happy':
        return Icons.sentiment_satisfied;
      case 'Excited':
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.error;
    }
  }
}