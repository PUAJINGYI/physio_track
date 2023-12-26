import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/ot_library/screen/ot_library_detail_screen.dart';
import 'package:physio_track/ot_library/service/ot_library_service.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../translations/locale_keys.g.dart';
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
                LocaleKeys.OT_Activity_Library.tr(),
                style: TextStyle(
                  fontSize: TextConstant.TITLE_FONT_SIZE,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 90,
            right: 0,
            left: 0,
            child: Center(
              child: Image.asset(
                ImageConstant.OT,
                height: 150.0,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 250),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.Title.tr(),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.Description.tr(),
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
                              labelText: LocaleKeys.Duration.tr(),
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
                              labelText: LocaleKeys.Level.tr(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextField(
                        controller: _videoUrlController,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.Video_URL.tr(),
                        ),
                      ),
                      SizedBox(height: 120),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            0,
                            TextConstant.CUSTOM_BUTTON_TB_PADDING,
                            0,
                            TextConstant.CUSTOM_BUTTON_TB_PADDING),
                        child: customButton(
                          context,
                          LocaleKeys.Save.tr(),
                          ColorConstant.GREEN_BUTTON_TEXT,
                          ColorConstant.GREEN_BUTTON_UNPRESSED,
                          ColorConstant.GREEN_BUTTON_PRESSED,
                          () {
                            _addOrUpdateOTActivity(widget.recordId!);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 45),
            ],
          ),
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
                          LocaleKeys.Duration.tr(),
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
            child: ListView(
              padding: EdgeInsets.zero,
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
            SnackBar(content: Text(LocaleKeys.OT_Activity_updated.tr())),
          );
          Navigator.pop(context, true);
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              titlePadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Error", style: TextStyle(fontSize: 18)),
                  IconButton(
                    icon:
                        Icon(Icons.close, color: ColorConstant.RED_BUTTON_TEXT),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Please enter a valid video URL.',
                  textAlign: TextAlign.center,
                ),
              ),
              actions: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: ColorConstant.BLUE_BUTTON_UNPRESSED,
                        ),
                        child: Text('OK',
                            style: TextStyle(
                                color: ColorConstant.BLUE_BUTTON_TEXT)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
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
            contentPadding: EdgeInsets.zero,
            titlePadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Error", style: TextStyle(fontSize: 18)),
                IconButton(
                  icon: Icon(Icons.close, color: ColorConstant.RED_BUTTON_TEXT),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Please fill in all the details.',
                textAlign: TextAlign.center,
              ),
            ),
            actions: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: ColorConstant.BLUE_BUTTON_UNPRESSED,
                      ),
                      child: Text('OK',
                          style:
                              TextStyle(color: ColorConstant.BLUE_BUTTON_TEXT)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    }
  }
}
