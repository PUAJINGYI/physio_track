import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/pt_library/screen/pt_library_list_screen.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../reusable_widget/reusable_widget.dart';
import '../service/pt_library_service.dart';

class AddPTActivityScreen extends StatefulWidget {
  const AddPTActivityScreen({super.key});

  @override
  State<AddPTActivityScreen> createState() => _AddPTActivityScreenState();
}

class _AddPTActivityScreenState extends State<AddPTActivityScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _catController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final YoutubeExplode _ytExplode = YoutubeExplode();

  // Regular expression to validate URL
  final _urlRegex = RegExp(
    r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?'
    r'[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}'
    r'(:[0-9]{1,5})?(\/.*)?$',
  );

  PTLibraryService ptLibraryService = PTLibraryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
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
                    GestureDetector(
                      onTap: () {
                        _showCatPicker(context);
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _catController,
                          decoration: InputDecoration(
                            labelText: 'Category',
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
                  ],
                ),
              ),
            ),
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
                'PT Activity Library',
                style: TextStyle(
                  fontSize: TextConstant.TITLE_FONT_SIZE,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 0,
            left: 0,
            child: Image.asset(
              ImageConstant.PT,
              width: 271.0,
              height: 170.0,
            ),
          ),
          Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: customButton(
                  context,
                  'Add',
                  ColorConstant.GREEN_BUTTON_TEXT,
                  ColorConstant.GREEN_BUTTON_UNPRESSED,
                  ColorConstant.GREEN_BUTTON_PRESSED,
                  () {
                    _addPTActivityLibrary();
                  },
                ),
              ))
        ],
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
                          Navigator.of(context)
                              .pop(); // Close the bottom s5heet
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Beginner',
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          setState(() {
                            selectedLevel = 'Beginner';
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Intermediate',
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          setState(() {
                            selectedLevel = 'Intermediate';
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Advanced',
                          textAlign: TextAlign.center,
                        ),
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

  Future<void> _showCatPicker(BuildContext context) async {
    String selectedCat = '';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext builder) {
        return GestureDetector(
          onTap: () {},
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
                          'Select Category',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            'Upper',
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            setState(() {
                              selectedCat = 'Upper';
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Lower',
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            setState(() {
                              selectedCat = 'Lower';
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Transfer',
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            setState(() {
                              selectedCat = 'Transfer';
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Breathing',
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            setState(() {
                              selectedCat = 'Breathing';
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Bed Mobility',
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            setState(() {
                              selectedCat = 'Bed Mobility';
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Passive Movement',
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            setState(() {
                              selectedCat = 'Passive Movement';
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Active Assisted Movement',
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            setState(() {
                              selectedCat = 'Active Assisted Movement';
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Sitting',
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            setState(() {
                              selectedCat = 'Sitting';
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Core Movement',
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            setState(() {
                              selectedCat = 'Core Movement';
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    _catController.text = selectedCat;
  }

  Future<void> _addPTActivityLibrary() async {
    String title = _titleController.text;
    String desc = _descriptionController.text;
    String level = _levelController.text;
    String cat = _catController.text;
    String videoUrl = _videoUrlController.text;
    int exp = 0;
    // Check if all the controllers have non-empty values
    if (title.isNotEmpty &&
        desc.isNotEmpty &&
        level.isNotEmpty &&
        videoUrl.isNotEmpty) {
      // Check the validity of the video URL
      if (_urlRegex.hasMatch(videoUrl)) {
        final videoId = YoutubePlayer.convertUrlToId(videoUrl);
        if (videoId != null) {
          final video = await _ytExplode.videos.get(videoId);
          final thumbnailUrl = video.thumbnails.highResUrl;
          int duration = int.parse(
              _durationController.text.split(' ')[0]); // Extract minutes

          if (level == 'Beginner') {
            exp = 10;
          } else if (level == 'Intermediate') {
            exp = 20;
          } else if (level == 'Advanced') {
            exp = 30;
          }

          ptLibraryService.addPTLibrary(
            title: title,
            description: desc,
            duration: duration,
            level: level,
            cat: cat,
            videoUrl: videoUrl,
            thumbnailUrl: thumbnailUrl,
            exp: exp,
          );
        }
        // Clear all the controllers after adding the PT library
        _titleController.clear();
        _descriptionController.clear();
        _durationController.clear();
        _levelController.clear();
        _catController.clear();
        _videoUrlController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("new PT Activity added")),
        );
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) =>
        //         PTLibraryListScreen(), // Replace NextPage with your desired page
        //   ),
        // );
        Navigator.pop(context);
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
  }
}
