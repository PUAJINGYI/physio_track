import 'package:flutter/material.dart';

class CustomWeatherIcon extends StatelessWidget {
  final String weather;
  final bool isSelected;

  const CustomWeatherIcon({
    required this.weather,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Replace with your custom weather icon widget
    return Icon(
      getWeatherIconData(weather),
      color: isSelected ? Colors.blue : Colors.grey,
      size: 40.0,
    );
  }

  IconData getWeatherIconData(String weather) {
    // Add your custom logic to map weather strings to IconData
    switch (weather) {
      case 'Sunny':
        return Icons.wb_sunny;
      case 'Cloudy':
        return Icons.cloud;
      case 'Rainy':
        return Icons.beach_access;
      case 'Snowing':
        return Icons.snowing;
      case 'Thundering':
        return Icons.flash_on;
      default:
        return Icons.error;
    }
  }
}