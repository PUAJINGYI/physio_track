// // import 'package:flutter/material.dart';
// // import 'package:googleapis/calendar/v3.dart' as calendar;

// // import '../service/google_calander_service.dart';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Google Calendar Event',
// //       // theme: ThemeData(
// //       //   primarySwatch: Colors.blue,
// //       // ),
// //       home: EventForm(), // Display the EventForm widget
// //     );
// //   }
// // }

// // class EventForm extends StatefulWidget {
// //   @override
// //   _EventFormState createState() => _EventFormState();
// // }

// // class _EventFormState extends State<EventForm> {
// //   final _formKey = GlobalKey<FormState>();
// //   final TextEditingController _eventTitleController = TextEditingController();
// //   final TextEditingController _eventDescriptionController =
// //       TextEditingController();
// //   final TextEditingController _eventDateController = TextEditingController();

// //   // Instantiate the GoogleCalendarService
// //   final GoogleCalendarService _calendarService = GoogleCalendarService();

// //   @override
// //   void dispose() {
// //     _eventTitleController.dispose();
// //     _eventDescriptionController.dispose();
// //     _eventDateController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _submitEvent() async {
// //     if (_formKey.currentState != null && _formKey.currentState!.validate()) {
// //       final event = calendar.Event()
// //         ..summary = _eventTitleController.text
// //         ..description = _eventDescriptionController.text;

// //       final eventDate = DateTime.parse(_eventDateController.text);
// //       final eventStart = eventDate.toUtc();
// //       final eventEnd = eventDate.add(Duration(hours: 1)).toUtc();

// //       event
// //         ..start =
// //             calendar.EventDateTime(dateTime: eventStart, timeZone: 'GMT+8')
// //         ..end = calendar.EventDateTime(dateTime: eventEnd, timeZone: 'GMT+8');

// //       try {
// //         // await _calendarService.insertEvent(_eventTitleController.text, eventStart,eventEnd,[]);
// //         // ScaffoldMessenger.of(context).showSnackBar(
// //         //   SnackBar(content: Text('Event added to Google Calendar???')),
// //         // );
// //       } catch (e) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Error adding event: $e')),
// //         );
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Add Event to Google Calendar'),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Form(
// //           key: _formKey,
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: <Widget>[
// //               TextFormField(
// //                 controller: _eventTitleController,
// //                 decoration: InputDecoration(labelText: 'Event Title'),
// //                 validator: (value) {
// //                   if (value != null && value.isEmpty) {
// //                     return 'Please enter an event title';
// //                   }
// //                   return null;
// //                 },
// //               ),
// //               TextFormField(
// //                 controller: _eventDescriptionController,
// //                 decoration: InputDecoration(labelText: 'Event Description'),
// //               ),
// //               TextFormField(
// //                 controller: _eventDateController,
// //                 decoration:
// //                     InputDecoration(labelText: 'Event Date (YYYY-MM-DD)'),
// //                 validator: (value) {
// //                   if (value!.isEmpty) {
// //                     return 'Please enter an event date';
// //                   }
// //                   return null;
// //                 },
// //               ),
// //               SizedBox(height: 16),
// //               ElevatedButton(
// //                 onPressed: _submitEvent,
// //                 child: Text('Add Event'),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // import 'package:flutter/material.dart';
// // // import 'package:googleapis/calendar/v3.dart';

// // // import '../service/google_calander_service.dart';

// // // void main() {
// // //   runApp(MyApp());
// // // }

// // // class MyApp extends StatelessWidget {
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       home: MyHomePage(),
// // //     );
// // //   }
// // // }

// // // class MyHomePage extends StatelessWidget {
// // //   final googleCalendarService = GoogleCalendarService(
// // //     apiKey: 'AIzaSyDH-ZqM3NE3Mi1HjL9eMOs0FgpYWfXCWbQ',
// // //     calendarId: 'puajingyi@gmail.com',
// // //     clientId:
// // //         '415705875568-hl59d6fg4n76lek4elhla1ai6s3dpkm3.apps.googleusercontent.com',
// // //     clientSecret: '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',
// // //     scopes: ['https://www.googleapis.com/auth/calendar'],
// // //   );

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text('Google Calendar Integration'),
// // //       ),
// // //       body: Center(
// // //         child: ElevatedButton(
// // //           onPressed: () {
// // //             createSampleEvent(context);
// // //           },
// // //           child: Text('Create Event on Google Calendar'),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   void createSampleEvent(BuildContext context) async {
// // //     final event = Event()
// // //       ..summary = 'Sample Event'
// // //       ..description = 'This is a test event'
// // //       ..start = EventDateTime(dateTime: DateTime.now(), timeZone: 'GMT+8')
// // //       ..end = EventDateTime(
// // //           dateTime: DateTime.now().add(Duration(hours: 1)), timeZone: 'GMT+8');

// // //     await googleCalendarService.createEvent(event);

// // //     // Optionally, display a message to the user indicating that the event was created.
// // //     // showDialog(
// // //     //   context: context,
// // //     //   builder: (BuildContext context) {
// // //     //     return AlertDialog(
// // //     //       title: Text('Event Created'),
// // //     //       content:
// // //     //           Text('The sample event has been created on Google Calendar.'),
// // //     //       actions: [
// // //     //         TextButton(
// // //     //           onPressed: () {
// // //     //             Navigator.of(context).pop();
// // //     //           },
// // //     //           child: Text('OK'),
// // //     //         ),
// // //     //       ],
// // //     //     );
// // //     //   },
// // //     // );
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(content: Text('Event Created')),
// // //     );
// // //   }
// // // }

// // import 'dart:developer';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

// // import '../service/google_calander_service.dart';

// // class Home extends StatefulWidget {
// //   @override
// //   _HomeState createState() => _HomeState();
// // }

// // class _HomeState extends State<Home> {
// //   CalendarClient calendarClient = CalendarClient();
// //   DateTime startTime = DateTime.now();
// //   DateTime endTime = DateTime.now().add(Duration(days: 1));
// //   TextEditingController _eventName = TextEditingController();
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: _body(context),
// //     );
// //   }

// //   _body(BuildContext context) {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: <Widget>[
// //           Row(
// //             children: <Widget>[
// //               ElevatedButton(
// //                   onPressed: () {
// //                     DatePicker.showDateTimePicker(context,
// //                         showTitleActions: true,
// //                         minTime: DateTime(2019, 3, 5),
// //                         maxTime: DateTime(2200, 6, 7), onChanged: (date) {
// //                       print('change $date');
// //                     }, onConfirm: (date) {
// //                       setState(() {
// //                         this.startTime = date;
// //                       });
// //                     }, currentTime: DateTime.now(), locale: LocaleType.en);
// //                   },
// //                   child: Text(
// //                     'Event Start Time',
// //                     style: TextStyle(color: Colors.blue),
// //                   )),
// //               Text('$startTime'),
// //             ],
// //           ),
// //           Row(
// //             children: <Widget>[
// //               ElevatedButton(
// //                   onPressed: () {
// //                     DatePicker.showDateTimePicker(context,
// //                         showTitleActions: true,
// //                         minTime: DateTime(2019, 3, 5),
// //                         maxTime: DateTime(2200, 6, 7), onChanged: (date) {
// //                       print('change $date');
// //                     }, onConfirm: (date) {
// //                       setState(() {
// //                         this.endTime = date;
// //                       });
// //                     }, currentTime: DateTime.now(), locale: LocaleType.en);
// //                   },
// //                   child: Text(
// //                     'Event End Time',
// //                     style: TextStyle(color: Colors.blue),
// //                   )),
// //               Text('$endTime'),
// //             ],
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.all(12.0),
// //             child: TextField(
// //               controller: _eventName,
// //               decoration: InputDecoration(hintText: 'Enter Event name'),
// //             ),
// //           ),
// //           ElevatedButton(
// //               child: Text(
// //                 'Insert Event',
// //               ),
// //              // color: Colors.grey,
// //               onPressed: () {
// //                 //log('add event pressed');
// //                 calendarClient.insert(
// //                   _eventName.text,
// //                   startTime,
// //                   endTime,
// //                 );
// //               }),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // void main() {
// //   runApp(MaterialApp(
// //     title: 'Calendar App',
// //     debugShowCheckedModeBanner: false,
// //     home: Home(),
// //   ));
// // }

// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
// import 'package:googleapis/calendar/v3.dart';
// import 'package:googleapis_auth/auth_io.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// import '../service/google_calander_service.dart';

// void main() {
//   runApp(MaterialApp(
//     title: 'Calendar App',
//     debugShowCheckedModeBanner: false,
//     home: HomeScreen(),
//   ));
// }

// Future<AuthClient> loadAuthClient() async {
//   final authClient = await clientViaUserConsent(
//     ClientId(
//       "415705875568-hl59d6fg4n76lek4elhla1ai6s3dpkm3.apps.googleusercontent.com",
//       "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",
//     ),
//     [CalendarApi.calendarScope],
//     (uri) async {
//       print("Please go to the following URL and grant access:");
//       print("  => $uri");
//       print("");

//       if (await canLaunch(uri)) {
//         await launch(uri);
//       } else {
//         throw 'Could not launch $uri';
//       }
//     },
//   );
//   return authClient;
// }

// //Future<AuthClient?> loadAuthClient() async {
// //   final Completer<AuthClient?> completer = Completer<AuthClient?>();

// //   InAppWebViewController? webViewController;

// //   final InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
// //     android: AndroidInAppWebViewOptions(
// //       useWideViewPort: true,
// //     ),
// //   );

// //   // Create the in-app WebView
// //   InAppWebView(
// //     initialUrlRequest: URLRequest(
// //       url: Uri.parse(
// //         "https://accounts.google.com/o/oauth2/auth"
// //         "?response_type=code"
// //         "&client_id=415705875568-hl59d6fg4n76lek4elhla1ai6s3dpkm3.apps.googleusercontent.com"
// //         "&redirect_uri=http://localhost"
// //         "&scope=${CalendarApi.calendarScope}",
// //       ),
// //     ),
// //     initialOptions: options,
// //     onWebViewCreated: (controller) {
// //       webViewController = controller;
// //     },
// //     onLoadStop: (controller, url) async {
// //       if (url.toString().startsWith('http://localhost')) {
// //         // Extract the authorization code from the URL and create the AuthClient
// //         final authCode = Uri.parse(url.toString()).queryParameters['code'];
// //         final authClient = await clientViaUserConsent(
// //           ClientId(
// //             "415705875568-hl59d6fg4n76lek4elhla1ai6s3dpkm3.apps.googleusercontent.com",
// //             "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",
// //           ),
// //           [CalendarApi.calendarScope],
// //           (Uri uri) {
// //             webViewController!.loadUrl(urlRequest: URLRequest(url: uri));
// //           } as PromptUserForConsent,
// //           hostedDomain: authCode,
// //         );
// //         completer.complete(authClient);
// //       }
// //     },
// //   );

// //   return completer.future;
// // }

// // Future<AuthClient> loadAuthClient(BuildContext context) async {
// //   final Completer<AuthClient> completer = Completer<AuthClient>();

// //   final authClient = await clientViaUserConsent(
// //     ClientId(
// //       "415705875568-hl59d6fg4n76lek4elhla1ai6s3dpkm3.apps.googleusercontent.com",
// //       "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",
// //     ),
// //     [CalendarApi.calendarScope],
// //     (uri) async {
// //       InAppWebViewController webViewController;

// //       InAppWebView(
// //         initialUrlRequest: URLRequest(url: Uri.parse(uri.toString())
// //         // , headers: { 'User-Agent': 'random'}
// //         ),
// //         initialOptions:
// // //         InAppWebViewGroupOptions(
// // //             crossPlatform: InAppWebViewOptions(
// // // // debuggingEnabled: true,
// // //           userAgent: 'random',
// // //           javaScriptEnabled: true,
// // //           useShouldOverrideUrlLoading: true,
// // //           useOnLoadResource: true,
// // //           cacheEnabled: true,
// // //         )),
// //             InAppWebViewGroupOptions(
// //                 android: AndroidInAppWebViewOptions(
// //           useHybridComposition: true,
// //         )),
// //         onWebViewCreated: (controller) {
// //           webViewController = controller;
// //         },
// //         onLoadStart: (controller, url) {
// //           // Handle page load start, if needed
// //         },
// //         onLoadStop: (controller, url) {
// //           // Handle page load stop, if needed
// //         },
// //         onProgressChanged: (controller, progress) {
// //           // Handle loading progress here, if needed
// //         },
// //         shouldOverrideUrlLoading: (controller, navigationAction) async {
// //           final url = navigationAction.request.url;

// //           if (url?.toString().startsWith('http://localhost') ?? false) {
// //             // Close the WebView when the redirect is detected
// //             Navigator.pop(context);
// //             return NavigationActionPolicy.CANCEL;
// //           }

// //           return NavigationActionPolicy.ALLOW;
// //         },
// //       );

// //       showDialog(
// //         context: context,
// //         builder: (BuildContext context) {
// //           return AlertDialog(
// //             title: Text("Grant Access"),
// //             content: Container(
// //               width: double.maxFinite,
// //               height: 400,
// //               child: InAppWebView(
// //                 initialUrlRequest: URLRequest(url: Uri.parse(uri.toString())),
// //                 onWebViewCreated: (controller) {
// //                   webViewController = controller;
// //                 },
// //               ),
// //             ),
// //           );
// //         },
// //       );
// //     },
// //   );

// //   completer.complete(authClient);
// //   return completer.future;
// // }
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//    WebViewController _webViewController = WebViewController();

//   Future<AuthClient> loadAuthClient(
//       BuildContext context, WebViewController controller) async {
//     final Completer<AuthClient> completer = Completer<AuthClient>();

//     final authClient = await clientViaUserConsent(
//       ClientId(
//         "415705875568-hl59d6fg4n76lek4elhla1ai6s3dpkm3.apps.googleusercontent.com",
//         "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",
//       ),
//       [CalendarApi.calendarScope],
//       (uri) async {
//         controller = WebViewController()
//           ..setJavaScriptMode(JavaScriptMode.unrestricted)
//           ..setBackgroundColor(const Color(0x00000000))
//           ..setNavigationDelegate(
//             NavigationDelegate(
//               onProgress: (int progress) {
//                 // Update loading bar.
//               },
//               onPageStarted: (String url) {},
//               onPageFinished: (String url) {},
//               onWebResourceError: (WebResourceError error) {},
//               onNavigationRequest: (NavigationRequest request) {
//                 if (request.url.toString().startsWith('http://localhost/')) {
//                   return NavigationDecision.prevent;
//                 }
//                 return NavigationDecision.navigate;
//               },
//             ),
//           )
//           ..loadRequest(Uri.parse('http://localhost/'));

//        showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text("Grant Access"),
//               content: Container(
//                 width: double.maxFinite,
//                 height: 400,
//                 child: WebViewWidget(controller: controller),
//               ),
//             );
//           },
//         );
//       },
//     );

//     completer.complete(authClient);
//     return completer.future;
//   }

//   void _onAuthenticateButtonPressed(BuildContext context) async {
//     final authClient = await loadAuthClient(context, _webViewController);

//     // Now you can use the authClient for authenticated API requests
//     // For example, you can use it to fetch calendar events
//     final calendarApi = CalendarApi(authClient);
//     final events = await calendarApi.events.list('primary');

//     // Handle the fetched events as needed
//     print('Calendar Events:');
//     if (events != null && events.items != null) {
//       for (final event in events.items!) {
//         print(event.summary);
//       }
//     } else {
//       // Handle the case where events or events.items is null
//       print('No events found.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Your App'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Welcome to Your App',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _onAuthenticateButtonPressed(context);
//               },
//               child: Text('Authenticate'),
//             ),
//             Expanded(
//               child: WebViewWidget(
//                 controller: _webViewController,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class Home extends StatefulWidget {
//   final Future<AuthClient> authClientFuture;

//   Home(this.authClientFuture);

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   GoogleCalendarService calendarClient = GoogleCalendarService();
//   DateTime startTime = DateTime.now();
//   DateTime endTime = DateTime.now().add(Duration(days: 1));
//   TextEditingController _eventName = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<AuthClient>(
//         future: widget.authClientFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // Loading state
//             return CircularProgressIndicator();
//           } else if (snapshot.hasError) {
//             // Error state
//             return Text('Error: ${snapshot.error}');
//           } else {
//             // AuthClient is ready, build your UI
//             return _buildUI(context, snapshot.data);
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildUI(BuildContext context, AuthClient? authClient) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Row(
//             children: <Widget>[
//               ElevatedButton(
//                 onPressed: () {
//                   DatePicker.showDateTimePicker(
//                     context,
//                     showTitleActions: true,
//                     minTime: DateTime(2019, 3, 5),
//                     maxTime: DateTime(2200, 6, 7),
//                     onChanged: (date) {
//                       print('change $date');
//                     },
//                     onConfirm: (date) {
//                       setState(() {
//                         this.startTime = date;
//                       });
//                     },
//                     currentTime: DateTime.now(),
//                     locale: LocaleType.en,
//                   );
//                 },
//                 child: Text(
//                   'Event Start Time',
//                 ),
//               ),
//               Text('$startTime'),
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               ElevatedButton(
//                 onPressed: () {
//                   DatePicker.showDateTimePicker(
//                     context,
//                     showTitleActions: true,
//                     minTime: DateTime(2019, 3, 5),
//                     maxTime: DateTime(2200, 6, 7),
//                     onChanged: (date) {
//                       print('change $date');
//                     },
//                     onConfirm: (date) {
//                       setState(() {
//                         this.endTime = date;
//                       });
//                     },
//                     currentTime: DateTime.now(),
//                     locale: LocaleType.en,
//                   );
//                 },
//                 child: Text(
//                   'Event End Time',
//                 ),
//               ),
//               Text('$endTime'),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: TextField(
//               controller: _eventName,
//               decoration: InputDecoration(hintText: 'Enter Event name'),
//             ),
//           ),
//           ElevatedButton(
//             child: Text(
//               'Insert Event',
//             ),
//             onPressed: () {
//               //log('add event pressed');
//               if (authClient != null) {
//                 calendarClient.insertEvent(
//                   _eventName.text,
//                   startTime,
//                   endTime,
//                   [],
//                   authClient, // Pass the authClient to CalendarClient
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
