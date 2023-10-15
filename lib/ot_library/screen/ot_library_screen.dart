import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/ot_library/service/ot_library_service.dart';

class AddOTActivityScreen extends StatefulWidget {
  const AddOTActivityScreen({super.key});

  @override
  State<AddOTActivityScreen> createState() => _AddOTActivityScreenState();
}

class _AddOTActivityScreenState extends State<AddOTActivityScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  // Regular expression to validate URL
  final _urlRegex = RegExp(
    r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?'
    r'[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}'
    r'(:[0-9]{1,5})?(\/.*)?$',
  );

  OTLibraryService otLibraryService = OTLibraryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Occupational Therapy Activity'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
              SizedBox(height: 16.0),
              // Replace the TextField with the NumberPicker
              GestureDetector(
                onTap: () {
                  _showDurationPicker(context);
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _durationController,
                    decoration: InputDecoration(
                      labelText: 'Duration (minutes)',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: () {
                  _showLevelPicker(context);
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _levelController,
                    decoration: InputDecoration(
                      labelText: 'Level',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _videoUrlController,
                decoration: InputDecoration(
                  labelText: 'Video URL',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  String title = _titleController.text;
                  String desc = _descriptionController.text;
                  String level = _levelController.text;
                  String videoUrl = _videoUrlController.text;

                  // Check if all the controllers have non-empty values
                  if (title.isNotEmpty &&
                      desc.isNotEmpty &&
                      level.isNotEmpty &&
                      videoUrl.isNotEmpty) {
                    // Check the validity of the video URL
                    if (_urlRegex.hasMatch(videoUrl)) {
                      int duration = int.parse(_durationController.text
                          .split(' ')[0]); // Extract minutes
                      otLibraryService.addOTLibrary(
                        title: title,
                        description: desc,
                        duration: duration,
                        level: level,
                        videoUrl: videoUrl,
                      );

                      // Clear all the controllers after adding the OT library
                      _titleController.clear();
                      _descriptionController.clear();
                      _durationController.clear();
                      _levelController.clear();
                      _videoUrlController.clear();
                    } else {
                      // Show an error message for invalid video URL
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text('Please enter a valid video URL.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    // Show an error message or handle the case where any of the fields are empty
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text('Please fill in all the fields.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDurationPicker(BuildContext context) async {
    int selectedDuration = 5; // Set the initial value here

    // Show the bottom sheet dialog
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext builder) {
        return GestureDetector(
          onTap: () {
            // Do nothing when tapped inside the dialog
          },
          child: Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Duration (mins)',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the bottom sheet
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                        initialItem: selectedDuration -
                            1), // Set initialItem to the selected duration
                    itemExtent: 32.0,
                    onSelectedItemChanged: (int value) {
                      selectedDuration = value + 1;
                      _durationController.text = "$selectedDuration minutes";
                    },
                    children: List<Widget>.generate(
                      100,
                      (int index) {
                        return Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(fontSize: 20.0),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLevelPicker(BuildContext context) async {
    String selectedLevel = '';

    // Show the bottom sheet dialog
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext builder) {
        return GestureDetector(
          onTap: () {
            // Do nothing when tapped inside the dialog
          },
          child: Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Select Level',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the bottom sheet
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Beginner'),
                        onTap: () {
                          setState(() {
                            selectedLevel = 'Beginner';
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        title: Text('Intermediate'),
                        onTap: () {
                          setState(() {
                            selectedLevel = 'Intermediate';
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        title: Text('Advanced'),
                        onTap: () {
                          setState(() {
                            selectedLevel = 'Advanced';
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Update the level textfield value after selecting the level
    _levelController.text = selectedLevel;
  }
}
