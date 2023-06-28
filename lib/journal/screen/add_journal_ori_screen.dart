// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
// import 'package:physio_track/journal/service/journal_service.dart';
// import 'package:physio_track/reusable_widget/reusable_widget.dart';

// import '../model/journal_model.dart';
// import '../widget/custom_feeling_icon.dart';
// import '../widget/custom_weather_icon.dart';

// class AddJournalOriScreen extends StatefulWidget {
//   const AddJournalOriScreen({super.key});

//   @override
//   State<AddJournalOriScreen> createState() => _AddJournalOriScreenState();
// }

// class _AddJournalOriScreenState extends State<AddJournalOriScreen> {
//   String userId = FirebaseAuth.instance.currentUser!.uid;
//   JournalService journalService = JournalService();
//   final _formKey = GlobalKey<FormState>();

//   String _title = '';
//   String _weather = '';
//   String _feeling = '';
//   double _healthCondition = 3.0;
//   String _comment = '';
//   int _journalId = 0;

//   List<String> weatherOptions = [
//     'Sunny',
//     'Cloudy',
//     'Rainy',
//     'Rainbow',
//     'Thundering'
//   ];

//   List<String> feelingOptions = [
//     'Depressed',
//     'Sad',
//     'Neutral',
//     'Happy',
//     'Excited'
//   ];

//   void createJournal() {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       Journal journal = Journal(
//         id: _journalId,
//         date: DateTime.now(),
//         title: _title,
//         weather: _weather,
//         feeling: _feeling,
//         healthCondition: _healthCondition.round().toString(),
//         comment: _comment,
//       );
//       // TODO: Handle saving the journal object
//       journalService.addJournal(userId, journal);
//       print('Journal: $journal');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Journal'),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 10.0),
//               Card(
//                 color: Colors.grey[200],
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
//                   child: TextFormField(
//                     decoration: InputDecoration(labelText: 'Title'),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a title';
//                       }
//                       return null;
//                     },
//                     onSaved: (value) {
//                       _title = value ?? '';
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16.0),
//               Card(
//                 color: Colors.grey[200],
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
//                   child: Column(
//                     children: [
//                       Text('Weather'),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: weatherOptions.map((option) {
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _weather = option;
//                               });
//                             },
//                             child: Column(
//                               children: [
//                                 // Replace with your custom weather icon
//                                 CustomWeatherIcon(
//                                   weather: option,
//                                   isSelected: _weather == option,
//                                 ),
//                                 Text(option, style: TextStyle(fontSize: 10.0)),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16.0),
//               Card(
//                 color: Colors.grey[200],
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
//                   child: Column(
//                     children: [
//                       Text('Today\'s Feeling'),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: feelingOptions.map((option) {
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _feeling = option;
//                               });
//                             },
//                             child: Column(
//                               children: [
//                                 // Replace with your custom feeling icon
//                                 CustomFeelingIcon(
//                                   feeling: option,
//                                   isSelected: _feeling == option,
//                                 ),
//                                 Text(option, style: TextStyle(fontSize: 10.0)),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16.0),
//               Card(
//                 color: Colors.grey[200],
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
//                   child: Column(
//                     children: [
//                       Text('Health Condition'),
//                       Slider(
//                         value: _healthCondition,
//                         min: 1.0,
//                         max: 5.0,
//                         divisions: 4,
//                         onChanged: (value) {
//                           setState(() {
//                             _healthCondition = value;
//                           });
//                         },
//                       ),
//                       Text('Value: ${_healthCondition.round()}'),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16.0),
//               Card(
//                 color: Colors.grey[200],
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
//                   child: TextFormField(
//                     decoration: InputDecoration(labelText: 'Comment'),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a comment';
//                       }
//                       return null;
//                     },
//                     onSaved: (value) {
//                       _comment = value ?? '';
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16.0),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
//                 child: customButton(context, 'Create', Colors.white, Color.fromARGB(255, 43, 222, 253), Color.fromARGB(255, 66, 157, 173), (){
//                   createJournal();
//                 }),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
