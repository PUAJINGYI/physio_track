// import 'dart:async';
// import 'dart:math';

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';

// class BarChartSample1 extends StatefulWidget {
//   BarChartSample1({super.key});

//   List<Color> get availableColors => const <Color>[
//         Color.fromRGBO(111, 0, 255, 1),
//         Color.fromRGBO(229, 255, 0, 1),
//         Color.fromRGBO(0, 81, 255, 1),
//         Color.fromRGBO(255, 123, 0, 1),
//         Color.fromRGBO(255, 0, 140, 1),
//         Color.fromRGBO(255, 0, 0, 1),
//       ];

//   final Color barBackgroundColor =
//       Colors.grey.withOpacity(0.1); // Colors.white.withOpacity(0.1);
//   final Color barColor = Colors.blue;
//   final Color touchedBarColor = Colors.yellow;

//   @override
//   State<StatefulWidget> createState() => BarChartSample1State();
// }

// class BarChartSample1State extends State<BarChartSample1> {
//   final Duration animDuration = const Duration(milliseconds: 250);

//   int touchedIndex = -1;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: <Widget>[
//                 const Text(
//                   'Hello',
//                   style: TextStyle(
//                     color: Colors.green,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 4,
//                 ),
//                 Text(
//                   'Grafik konsumsi kalori',
//                   style: TextStyle(
//                     color: Colors.green[900],
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 38,
//                 ),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(
//                       16.0), // Adjust the radius as needed
//                   child: Container(
//                     color: Color.fromARGB(255, 169, 215, 252),
//                     height: 250,
//                     child: Padding(
//                       padding: EdgeInsets.fromLTRB(8, 15, 8, 8),
//                       child: GroupedBarChart(),
//                       // BarChart(
//                       //   mainBarData(),
//                       //   swapAnimationDuration: animDuration,
//                       // ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 12,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   BarChartGroupData makeGroupData(
//     int x,
//     double y1,
//     double y2, {
//     bool isTouched = false,
//     Color? barColor,
//     double width = 15,
//     List<int> showTooltips = const [],
//   }) {
//     barColor ??= widget.barColor;
//     return BarChartGroupData(
//       x: x,
//       barRods: [
//         BarChartRodData(
//           toY: isTouched ? y1 + 1 : y1,
//           color: isTouched ? widget.touchedBarColor : barColor,
//           width: width,
//           borderSide: isTouched
//               ? BorderSide(color: widget.touchedBarColor)
//               : const BorderSide(color: Colors.white, width: 0),
//           backDrawRodData: BackgroundBarChartRodData(
//             show: true,
//             //background bar percentage
//             toY: 100,
//             color: widget.barBackgroundColor,
//           ),
//         ),
//         BarChartRodData(
//           toY: isTouched ? y2 + 1 : y2,
//           color: isTouched ? widget.touchedBarColor : Colors.red,
//           width: width,
//           borderSide: isTouched
//               ? BorderSide(color: widget.touchedBarColor)
//               : const BorderSide(color: Colors.white, width: 0),
//           backDrawRodData: BackgroundBarChartRodData(
//             show: true,
//             //background bar percentage
//             toY: 100,
//             color: widget.barBackgroundColor,
//           ),
//         ),
//       ],
//       showingTooltipIndicators: showTooltips,
//     );
//   }

//   List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
//         switch (i) {
//           case 0:
//             return makeGroupData(0, 20, 30, isTouched: i == touchedIndex);
//           case 1:
//             return makeGroupData(1, 6.5, 40, isTouched: i == touchedIndex);
//           case 2:
//             return makeGroupData(2, 5, 45, isTouched: i == touchedIndex);
//           case 3:
//             return makeGroupData(3, 7.5, 20, isTouched: i == touchedIndex);
//           case 4:
//             return makeGroupData(4, 9, 10, isTouched: i == touchedIndex);
//           case 5:
//             return makeGroupData(5, 20.0, 55, isTouched: i == touchedIndex);
//           case 6:
//             return makeGroupData(6, 6.5, 67, isTouched: i == touchedIndex);
//           default:
//             return throw Error();
//         }
//       });

//   BarChartData mainBarData() {
//     return BarChartData(
//       barTouchData: BarTouchData(
//         touchTooltipData: BarTouchTooltipData(
//           tooltipBgColor: Colors.blueGrey,
//           // tooltipHorizontalAlignment: FLHorizontalAlignment.center,
//           tooltipMargin: -10,
//           getTooltipItem: (group, groupIndex, rod, rodIndex) {
//             String weekDay;
//             switch (group.x) {
//               case 0:
//                 weekDay = 'Monday';
//                 break;
//               case 1:
//                 weekDay = 'Tuesday';
//                 break;
//               case 2:
//                 weekDay = 'Wednesday';
//                 break;
//               case 3:
//                 weekDay = 'Thursday';
//                 break;
//               case 4:
//                 weekDay = 'Friday';
//                 break;
//               case 5:
//                 weekDay = 'Saturday';
//                 break;
//               case 6:
//                 weekDay = 'Sunday';
//                 break;
//               default:
//                 throw Error();
//             }
//             return BarTooltipItem(
//               '$weekDay\n',
//               const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 10,
//               ),
//               children: <TextSpan>[
//                 TextSpan(
//                   text: (rod.toY - 1).toString(),
//                   style: TextStyle(
//                     color: widget.touchedBarColor,
//                     fontSize: 10,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//         touchCallback: (FlTouchEvent event, barTouchResponse) {
//           setState(() {
//             if (!event.isInterestedForInteractions ||
//                 barTouchResponse == null ||
//                 barTouchResponse.spot == null) {
//               touchedIndex = -1;
//               return;
//             }
//             touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
//           });
//         },
//       ),
//       titlesData: FlTitlesData(
//         show: true,
//         rightTitles: AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         topTitles: AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         bottomTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             getTitlesWidget: getTitles,
//             reservedSize: 38,
//           ),
//         ),
//         leftTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: false,
//           ),
//         ),
//       ),
//       borderData: FlBorderData(
//         show: false,
//       ),
//       barGroups: showingGroups(),
//       gridData: FlGridData(show: false),
//     );
//   }

//   Widget getTitles(double value, TitleMeta meta) {
//     const style = TextStyle(
//       color: Colors.white,
//       fontWeight: FontWeight.bold,
//       fontSize: 14,
//     );
//     Widget text;
//     switch (value.toInt()) {
//       case 0:
//         text = const Text('Mon', style: style);
//         break;
//       case 1:
//         text = const Text('Tue', style: style);
//         break;
//       case 2:
//         text = const Text('Wed', style: style);
//         break;
//       case 3:
//         text = const Text('Thu', style: style);
//         break;
//       case 4:
//         text = const Text('Fri', style: style);
//         break;
//       case 5:
//         text = const Text('Sat', style: style);
//         break;
//       case 6:
//         text = const Text('Sun', style: style);
//         break;
//       default:
//         text = const Text('', style: style);
//         break;
//     }
//     return SideTitleWidget(
//       axisSide: meta.axisSide,
//       space: 16,
//       child: text,
//     );
//   }
// }

// // class GroupedBarChart extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: EdgeInsets.all(16.0),
// //       child: BarChart(
// //         BarChartData(
// //           gridData: FlGridData(show: false),
// //           titlesData: FlTitlesData(show: false),
// //           borderData: FlBorderData(show: false),
// //           barGroups: _barGroups(),
// //           groupsSpace: 12.0,
// //         ),
// //       ),
// //     );
// //   }

// //   List<BarChartGroupData> _barGroups() {
// //     return [
// //       BarChartGroupData(
// //         x: 0,
// //         barRods: [
// //           BarChartRodData(toY: 5, color: Colors.blue),
// //           BarChartRodData(toY: 8, color: Colors.green),
// //           BarChartRodData(toY: 4, color: Colors.orange),
// //           BarChartRodData(toY: 7, color: Colors.red),
// //         ],
// //         showingTooltipIndicators: [0, 1, 2, 3],
// //       ),
// //       BarChartGroupData(
// //         x: 1,
// //         barRods: [
// //           BarChartRodData(toY: 4, color: Colors.blue),
// //           BarChartRodData(toY: 7, color: Colors.green),
// //           BarChartRodData(toY: 3, color: Colors.orange),
// //           BarChartRodData(toY: 6, color: Colors.red),
// //         ],
// //         showingTooltipIndicators: [0, 1, 2, 3],
// //       ),
// //       BarChartGroupData(
// //         x: 2,
// //         barRods: [
// //           BarChartRodData(toY: 6, color: Colors.blue),
// //           BarChartRodData(toY: 9, color: Colors.green),
// //           BarChartRodData(toY: 5, color: Colors.orange),
// //           BarChartRodData(toY: 8, color: Colors.red),
// //         ],
// //         showingTooltipIndicators: [0, 1, 2, 3],
// //       ),
// //       BarChartGroupData(
// //         x: 3,
// //         barRods: [
// //           BarChartRodData(toY: 7, color: Colors.blue),
// //           BarChartRodData(toY: 5, color: Colors.green),
// //           BarChartRodData(toY: 6, color: Colors.orange),
// //           BarChartRodData(toY: 9, color: Colors.red),
// //         ],
// //         showingTooltipIndicators: [0, 1, 2, 3],
// //       ),
// //     ];
// //   }
// // }

// class GroupedBarChart extends StatefulWidget {
//   @override
//   _GroupedBarChartState createState() => _GroupedBarChartState();
// }

// class _GroupedBarChartState extends State<GroupedBarChart> {
//   int touchedGroupIndex = -1;
//   int touchedRodIndex = -1;
//    int touchedIndex = -1;
//   final List<BarChartGroupData> barChartData = [
//     BarChartGroupData(
//       x: 0,
//       barRods: [
//         BarChartRodData(toY: 2),
//         BarChartRodData(toY: 4),
//         BarChartRodData(toY: 6),
//         BarChartRodData(toY: 8),
//       ],
//     ),
//     BarChartGroupData(
//       x: 1,
//       barRods: [
//         BarChartRodData(toY: 3),
//         BarChartRodData(toY: 6),
//         BarChartRodData(toY: 9),
//         BarChartRodData(toY: 12),
//       ],
//     ),
//     BarChartGroupData(
//       x: 2,
//       barRods: [
//         BarChartRodData(toY: 1),
//         BarChartRodData(toY: 2),
//         BarChartRodData(toY: 3),
//         BarChartRodData(toY: 4),
//       ],
//     ),
//     BarChartGroupData(
//       x: 3,
//       barRods: [
//         BarChartRodData(toY: 5),
//         BarChartRodData(toY: 10),
//         BarChartRodData(toY: 15),
//         BarChartRodData(toY: 20),
//       ],
//     ),
//     BarChartGroupData(
//       x: 4,
//       barRods: [
//         BarChartRodData(toY: 4),
//         BarChartRodData(toY: 8),
//         BarChartRodData(toY: 12),
//         BarChartRodData(toY: 16),
//       ],
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: AspectRatio(
//         aspectRatio: 1.5, // Adjust the aspect ratio as needed
//         child: BarChart(
//           BarChartData(
//             gridData: FlGridData(show: false),
//             titlesData: FlTitlesData(
//               topTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: false,
//                 ),
//               ),
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: false,
//                 ),
//               ),
//               rightTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: false,
//                 ),
//               ),
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   getTitlesWidget: getTitles,
//                 ),
//               ),
//             ),
//             borderData: FlBorderData(show: false),
//             groupsSpace: 40,
//             barGroups: barChartData.map((group) {
//               return BarChartGroupData(
//                 x: group.x,
//                 barRods: group.barRods,
//               );
//             }).toList(),
//             // Set the touch data for tooltips
//             barTouchData: BarTouchData(
//               touchTooltipData: BarTouchTooltipData(
//                 tooltipBgColor: Colors.blueGrey,
//                 getTooltipItems: (List<BarTooltipItem> items) {
//                   return items.map((item) {
//                     return BarTooltipItem(
//                       '${item.y.toString()}',
//                       TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     );
//                   }).toList();
//                 },
//               ),
//                      touchCallback: (FlTouchEvent event, barTouchResponse) {
//           setState(() {
//             if (!event.isInterestedForInteractions ||
//                 barTouchResponse == null ||
//                 barTouchResponse.spot == null) {
//               touchedIndex = -1;
//               return;
//             }
//             touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
//           });
//         },
//               touchTooltipThreshold: 0,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget getTitles(double value, TitleMeta meta) {
//     const style = TextStyle(
//       color: Colors.white,
//       fontWeight: FontWeight.bold,
//       fontSize: 14,
//     );
//     Widget text;
//     switch (value.toInt()) {
//       case 0:
//         text = const Text('Mon', style: style);
//         break;
//       case 1:
//         text = const Text('Tue', style: style);
//         break;
//       case 2:
//         text = const Text('Wed', style: style);
//         break;
//       case 3:
//         text = const Text('Thu', style: style);
//         break;
//       case 4:
//         text = const Text('Fri', style: style);
//         break;
//       case 5:
//         text = const Text('Sat', style: style);
//         break;
//       case 6:
//         text = const Text('Sun', style: style);
//         break;
//       default:
//         text = const Text('', style: style);
//         break;
//     }
//     return SideTitleWidget(
//       axisSide: meta.axisSide,
//       space: 16,
//       child: text,
//     );
//   }
// }
