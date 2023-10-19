import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:physio_track/journal/screen/view_journal_list_screen.dart';
import 'package:physio_track/journal/screen/view_journal_screen.dart';
import 'package:physio_track/journal/service/journal_service.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../model/journal_model.dart';
import '../widget/custom_feeling_icon.dart';
import '../widget/custom_weather_icon.dart';

class EditJournalScreen extends StatefulWidget {
  final int journalId;

  const EditJournalScreen({Key? key, required this.journalId})
      : super(key: key);

  @override
  State<EditJournalScreen> createState() => _EditJournalScreenState();
}

class _EditJournalScreenState extends State<EditJournalScreen> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  JournalService journalService = JournalService();
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  bool _imageUploaded = false;

  String _title = '';
  String _weather = '';
  String _feeling = '';
  double _healthCondition = 3.0;
  String _comment = '';
  String _imageUrl = '';

  TextEditingController _titleController = TextEditingController();
  TextEditingController _commentController = TextEditingController();

  List<String> weatherOptions = [
    'Sunny',
    'Cloudy',
    'Rainy',
    'Snowing',
    'Thundering'
  ];

  List<String> feelingOptions = [
    'Depressed',
    'Sad',
    'Neutral',
    'Happy',
    'Excited'
  ];

  @override
  void initState() {
    super.initState();
    loadJournalData();
  }

  void loadJournalData() async {
    Journal journal =
        await journalService.fetchJournal(userId, widget.journalId);
    setState(() {
      _title = journal.title;
      _weather = journal.weather;
      _feeling = journal.feeling;
      _healthCondition = double.parse(journal.healthCondition);
      _comment = journal.comment;
      _imageUrl = journal.imageUrl;
      _titleController = TextEditingController(text: _title);
      _commentController = TextEditingController(text: _comment);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
        _imageUploaded = true;
      });
    }
  }

  void updateJournal() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String _url = ''; // Initialize imageUrl with an empty string

      if (_imageFile != null) {
        // Upload the image to Firestorage
        _url = await uploadImageToFirestorage();
      }

      Journal journal = Journal(
        id: widget.journalId,
        date: DateTime.now(),
        title: _title,
        weather: _weather,
        feeling: _feeling,
        healthCondition: _healthCondition.round().toString(),
        comment: _comment,
        imageUrl: _url, // Assign the uploaded imageUrl to the journal
      );

      // TODO: Handle saving the journal object
      journalService.updateJournal(userId, widget.journalId, journal);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Journal updated successfully!")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewJournalListScreen(),
        ),
      );
      print('Journal: $journal');
    }
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text("No changes made!")),
    // );
  }

  Future<String> uploadImageToFirestorage() async {
    final storage = FirebaseStorage.instance;
    final storageRef = storage.ref();
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    final journalImageRef =
        storageRef.child('journal_images').child('$imageName.jpg');

    await journalImageRef.putFile(_imageFile!);
    String imageUrl = await journalImageRef.getDownloadURL();
    return imageUrl;
  }

  Image _getImage(_imageUploaded, _imageUrl, _imageFile) {
    if (_imageFile != null) {
      return Image.file(
        _imageFile,
        fit: BoxFit.cover,
      );
    }

    if (_imageUrl.isNotEmpty) {
      return Image.network(
        _imageUrl,
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      ImageConstant.DEFAULT_JOURNAL,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: kToolbarHeight),
                  // SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Add Title',
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(31, 121, 255, 0.3),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _title = value ?? '';
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 100.0),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Stack(
                      children: [
                        Card(
                          color: Color.fromRGBO(131, 183, 200, 0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 60.0),
                                Center(
                                  child: Text(
                                    formattedDate, // Add the formatted date here
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(5, 117, 155, 1),
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  color: Color.fromRGBO(241, 243, 250, 1),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 10, 20, 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Today\'s Weather',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(1, 101, 134, 1),
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children:
                                              weatherOptions.map((option) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _weather = option;
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  CustomWeatherIcon(
                                                    weather: option,
                                                    isSelected:
                                                        _weather == option,
                                                  ),
                                                  Text(
                                                    option,
                                                    style: TextStyle(
                                                        fontSize: 10.0),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  color: Color.fromRGBO(241, 243, 250, 1),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 10, 20, 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Today\'s Feeling',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(1, 101, 134, 1),
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children:
                                              feelingOptions.map((option) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _feeling = option;
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  // Replace with your custom feeling icon
                                                  CustomFeelingIcon(
                                                    feeling: option,
                                                    isSelected:
                                                        _feeling == option,
                                                  ),
                                                  Text(
                                                    option,
                                                    style: TextStyle(
                                                        fontSize: 10.0),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  color: Color.fromRGBO(241, 243, 250, 1),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 10, 20, 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Health Condition',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(1, 101, 134, 1),
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Bad',
                                                style: TextStyle(fontSize: 12)),
                                            Text('Great',
                                                style: TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                        Slider(
                                          value: _healthCondition,
                                          min: 1.0,
                                          max: 5.0,
                                          divisions: 4,
                                          onChanged: (value) {
                                            setState(() {
                                              _healthCondition = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  color: Color.fromRGBO(241, 243, 250, 1),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 10, 20, 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Comment of Day',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(1, 101, 134, 1),
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        TextFormField(
                                          controller: _commentController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter Something',
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.never,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a comment';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) {
                                            _comment = value ?? '';
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: customButton(
                        context,
                        'Save',
                        ColorConstant.BLUE_BUTTON_TEXT,
                        ColorConstant.BLUE_BUTTON_UNPRESSED,
                        ColorConstant.BLUE_BUTTON_PRESSED, () {
                      updateJournal();
                    }),
                  )
                ],
              ),
              Positioned(
                top: 25,
                left: 0,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: 35.0,
                  ),
                  onPressed: () {
                    // Perform your desired action here
                    // For example, navigate to the previous screen
                    Navigator.pop(context);
                  },
                ),
              ),
              Positioned(
                top: 25,
                left: 0,
                right: 0,
                child: Container(
                  height: kToolbarHeight,
                  alignment: Alignment.center,
                  child: Text(
                    'Journal',
                    style: TextStyle(
                      fontSize: TextConstant.TITLE_FONT_SIZE,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 135,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 160.0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        color: Colors
                            .grey, // Replace with your desired container color
                        child: Opacity(
                            opacity: _imageUploaded
                                ? 1.0
                                : 0.5, // Adjust the opacity value as needed
                            child: _getImage(
                                _imageUploaded, _imageUrl, _imageFile)),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 190,
                left: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(
                    Icons.cloud_upload,
                    size: 40,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _pickImage();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
