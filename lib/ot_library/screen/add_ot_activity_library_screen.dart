import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/ot_library/screen/ot_library_list_screen.dart';
import 'package:physio_track/ot_library/screen/ot_library_list_screen.dart';
import 'package:physio_track/ot_library/service/ot_library_service.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../translations/locale_keys.g.dart';

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
  final YoutubeExplode _ytExplode = YoutubeExplode();

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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                      // Replace the TextField with the NumberPicker
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
                      SizedBox(height: 120.0),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            0,
                            TextConstant.CUSTOM_BUTTON_TB_PADDING,
                            0,
                            TextConstant.CUSTOM_BUTTON_TB_PADDING),
                        child: customButton(
                          context,
                          LocaleKeys.Add.tr(),
                          ColorConstant.GREEN_BUTTON_TEXT,
                          ColorConstant.GREEN_BUTTON_UNPRESSED,
                          ColorConstant.GREEN_BUTTON_PRESSED,
                          () {
                            _addOTActivityLibrary();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              //SizedBox(height: 45),
            ],
          ),
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
                      _durationController.text =
                          "$selectedDuration ${LocaleKeys.minutes.tr()}";
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
                          LocaleKeys.Select_Level.tr(),
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
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        title: Text(
                          LocaleKeys.Beginner.tr(),
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
                          LocaleKeys.Intermediate.tr(),
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
                          LocaleKeys.Advanced.tr(),
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

  Future<void> _addOTActivityLibrary() async {
    String title = _titleController.text;
    String desc = _descriptionController.text;
    String level = _levelController.text;
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

          otLibraryService.addOTLibrary(
            title: title,
            description: desc,
            duration: duration,
            level: level,
            videoUrl: videoUrl,
            thumbnailUrl: thumbnailUrl,
            exp: exp,
          );
        }
        // Clear all the controllers after adding the OT library
        _titleController.clear();
        _descriptionController.clear();
        _durationController.clear();
        _levelController.clear();
        _videoUrlController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleKeys.New_OT_Activity_Added)),
        );
        Navigator.pop(context, true);
      } else {
        // Show an error message for invalid video URL
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
                  Text(LocaleKeys.Error.tr(), style: TextStyle(fontSize: 18)),
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
                  LocaleKeys.Please_enter_a_valid_video_URL.tr(),
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
                        child: Text(LocaleKeys.OK.tr(),
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
      // Show an error message or handle the case where any of the fields are empty
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
                Text(LocaleKeys.Error.tr(), style: TextStyle(fontSize: 18)),
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
                LocaleKeys.Please_fill_in_all_the_fields.tr(),
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
                      child: Text(LocaleKeys.OK.tr(),
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
