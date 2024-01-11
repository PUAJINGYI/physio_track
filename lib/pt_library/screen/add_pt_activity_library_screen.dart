import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../reusable_widget/reusable_widget.dart';
import '../../translations/locale_keys.g.dart';
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
                      GestureDetector(
                        onTap: () {
                          _showCatPicker(context);
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _catController,
                            decoration: InputDecoration(
                              labelText: LocaleKeys.Category.tr(),
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
                      SizedBox(height: 40),
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
                            _addPTActivityLibrary();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
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
                LocaleKeys.PT_Activity_Library.tr(),
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
                ImageConstant.PT,
                height: 150.0,
                fit: BoxFit.fitHeight,
              ),
            ),
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
          onTap: () {
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
                          Navigator.of(context).pop(); 
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                        initialItem: selectedDuration -
                            1), 
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

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext builder) {
        return GestureDetector(
          onTap: () {
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
                              .pop(); 
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
                          LocaleKeys.Select_Category.tr(),
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
                            LocaleKeys.Upper.tr(),
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
                            LocaleKeys.Lower.tr(),
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
                            LocaleKeys.Transfer.tr(),
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
                            LocaleKeys.Breathing.tr(),
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
                            LocaleKeys.Bed_Mobility.tr(),
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
                            LocaleKeys.Passive_Movement.tr(),
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
                            LocaleKeys.Active_Assisted_Movement.tr(),
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
                            LocaleKeys.Sitting.tr(),
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
                            LocaleKeys.Core_Movement.tr(),
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
    if (title.isNotEmpty &&
        desc.isNotEmpty &&
        level.isNotEmpty &&
        videoUrl.isNotEmpty) {
      if (_urlRegex.hasMatch(videoUrl)) {
        final videoId = YoutubePlayer.convertUrlToId(videoUrl);
        if (videoId != null) {
          final video = await _ytExplode.videos.get(videoId);
          final thumbnailUrl = video.thumbnails.highResUrl;
          int duration = int.parse(
              _durationController.text.split(' ')[0]); 

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
        _titleController.clear();
        _descriptionController.clear();
        _durationController.clear();
        _levelController.clear();
        _catController.clear();
        _videoUrlController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleKeys.New_PT_Activity_Added.tr())),
        );
        Navigator.pop(context, true);
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(LocaleKeys.Error.tr()),
            content: Text(LocaleKeys.Please_fill_in_all_the_fields.tr()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(LocaleKeys.OK.tr()),
              ),
            ],
          );
        },
      );
    }
  }
}
