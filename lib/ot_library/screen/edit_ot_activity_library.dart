import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/ot_library/screen/ot_library_detail_screen.dart';
import 'package:physio_track/ot_library/service/ot_library_service.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../model/ot_library_model.dart';

class EditOTActivityScreen extends StatefulWidget {
  final int? recordId;

  EditOTActivityScreen({Key? key, this.recordId}) : super(key: key);

  @override
  _EditOTActivityScreenState createState() => _EditOTActivityScreenState();
}

class _EditOTActivityScreenState extends State<EditOTActivityScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _levelController = TextEditingController();
  TextEditingController _videoUrlController = TextEditingController();
  TextEditingController _durationController = TextEditingController();

  RegExp _urlRegex = RegExp(
    r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?'
    r'[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}'
    r'(:[0-9]{1,5})?(\/.*)?$',
  );

  late OTLibraryService otLibraryService;
  final YoutubeExplode _ytExplode = YoutubeExplode();

  @override
  void initState() {
    super.initState();
    otLibraryService = OTLibraryService();

    if (widget.recordId != null) {
      _loadOTActivity();
    }
  }

  void _loadOTActivity() async {
    try {
      OTLibrary? otActivity =
          await otLibraryService.fetchOTLibrary(widget.recordId!);
      if (otActivity != null) {
        setState(() {
          _titleController.text = otActivity.title;
          _descriptionController.text = otActivity.description;
          _levelController.text = otActivity.level;
          _videoUrlController.text = otActivity.videoUrl;
          _durationController.text = '${otActivity.duration} minutes';
        });
      }
    } catch (e) {
      print('Error loading OT activity: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                'OT Activity Library',
                style: TextStyle(
                  fontSize: 20.0,
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
              ImageConstant.OT,
              width: 271.0,
              height: 170.0,
            ),
          ),
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
                  ],
                ),
              ),
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
                'Save',
                ColorConstant.GREEN_BUTTON_TEXT,
                ColorConstant.GREEN_BUTTON_UNPRESSED,
                ColorConstant.GREEN_BUTTON_PRESSED,
                () {
                  _addOrUpdateOTActivity(widget.recordId!);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showDurationPicker(BuildContext context) async {
    int selectedDuration = 5;

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
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                        initialItem: selectedDuration - 1),
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
                          'Select Level',
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

    _levelController.text = selectedLevel;
  }

  Future<void> _addOrUpdateOTActivity(int recordId) async {
    String title = _titleController.text;
    String desc = _descriptionController.text;
    String level = _levelController.text;
    String videoUrl = _videoUrlController.text;
    int exp = 0;

    if (title.isNotEmpty &&
        desc.isNotEmpty &&
        level.isNotEmpty &&
        videoUrl.isNotEmpty) {
      if (_urlRegex.hasMatch(videoUrl)) {
        int duration = int.parse(_durationController.text.split(' ')[0]);
        final videoId = YoutubePlayer.convertUrlToId(videoUrl);

        if (widget.recordId != null && videoId != null) {
          final video = await _ytExplode.videos.get(videoId);
          final thumbnailUrl = video.thumbnails.highResUrl;

          if (level == 'Beginner') {
            exp = 10;
          } else if (level == 'Intermediate') {
            exp = 20;
          } else if (level == 'Advanced') {
            exp = 30;
          }

          OTLibrary updatedOTActivity = OTLibrary(
            id: widget.recordId!,
            title: title,
            description: desc,
            duration: duration,
            level: level,
            videoUrl: videoUrl,
            thumbnailUrl: thumbnailUrl,
            exp: exp,
          );

          await otLibraryService.updateOTLibrary(
            id: widget.recordId!,
            title: title,
            description: desc,
            duration: duration,
            level: level,
            videoUrl: videoUrl,
            thumbnailUrl: thumbnailUrl,
            exp: exp,
          );

          setState(() {
            // Update the state with the new or updated data
            _titleController.text = updatedOTActivity.title;
            _descriptionController.text = updatedOTActivity.description;
            _levelController.text = updatedOTActivity.level;
            _videoUrlController.text = updatedOTActivity.videoUrl;
            _durationController.text = '${updatedOTActivity.duration} minutes';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("OT Activity updated")),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTLibraryDetailScreen(
                  recordId:
                      recordId), // Replace NextPage with your desired page
            ),
          );
        }
      } else {
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
