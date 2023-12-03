import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/TextConstant.dart';
import '../../notification/service/notification_service.dart';
import '../../notification/widget/shimmering_text_list_widget.dart';
import '../../translations/locale_keys.g.dart';
import '../model/ot_library_model.dart';
import '../service/ot_library_service.dart';
import 'edit_ot_activity_library.dart';
import 'ot_library_list_screen.dart';

class OTLibraryDetailScreen extends StatefulWidget {
  final int recordId;
  OTLibraryDetailScreen({required this.recordId});

  @override
  _OTLibraryDetailScreenState createState() => _OTLibraryDetailScreenState();
}

class _OTLibraryDetailScreenState extends State<OTLibraryDetailScreen> {
  late OTLibrary _otLibraryRecord;
  final OTLibraryService _otLibraryService = OTLibraryService();
  late YoutubePlayerController _controller;
  NotificationService notificationService = NotificationService();

  Future<void> _loadOTLibraryRecord() async {
    try {
      _otLibraryRecord =
          (await _otLibraryService.fetchOTLibrary(widget.recordId))!;
    } catch (e) {
      print('Error fetching OTLibrary record: $e');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  String extractVideoIdFromUrl(String url) {
    // Check if the URL contains 'v='
    final startIndex = url.indexOf('v=');
    if (startIndex != -1) {
      // Find the '&' character or the end of the string, whichever comes first
      final endIndex = url.indexOf('&', startIndex);
      if (endIndex != -1) {
        // Extract the substring between 'v=' and '&' (or end of string)
        return url.substring(startIndex + 2, endIndex);
      } else {
        // If there's no '&', return the substring from 'v=' to the end of the string
        return url.substring(startIndex + 2);
      }
    }
    // If 'v=' is not found in the URL, return an empty string or handle it as needed
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadOTLibraryRecord(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Ensure that the OTLibrary record is loaded
          final videoUrl = _otLibraryRecord.videoUrl;
          final id = extractVideoIdFromUrl(videoUrl);
          print('videoUrl: ${videoUrl}');

          _controller = YoutubePlayerController.fromVideoId(
            videoId: id,
            autoPlay: false,
            params: const YoutubePlayerParams(
                showControls: true,
                mute: false,
                showFullscreenButton: true,
                loop: false,
                enableJavaScript: false,
                color: 'red'),
          );

          _controller.setFullScreenListener(
            (isFullScreen) {
              log('${isFullScreen ? 'Entered' : 'Exited'} Fullscreen.');
            },
          );
          return YoutubePlayerScaffold(
            controller: _controller,
            builder: (context, player) {
              return Scaffold(
                body: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (kIsWeb && constraints.maxWidth > 750) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 40.0),
                              Expanded(
                                flex: 20,
                                child: Column(
                                  children: [
                                    player,
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: FutureBuilder(
                                        future:
                                            notificationService.translateText(
                                                _otLibraryRecord.title,
                                                context),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<String> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return ShimmeringTextListWidget(
                                                width: 300, numOfLines: 2);
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            String title = snapshot.data!;
                                            return Text(
                                              title,
                                              style: TextStyle(
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color: Colors.blue[500]!,
                                              width: 2.0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.access_time,
                                                  color: Colors.blue[500]),
                                              SizedBox(width: 4.0),
                                              Text(
                                                '${_otLibraryRecord.duration} ${LocaleKeys.minutes.tr()}',
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.blue[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        Container(
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color: _getLevelColor(
                                                  _otLibraryRecord.level),
                                              width: 2.0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.directions_run,
                                                  color: _getLevelColor(
                                                      _otLibraryRecord.level)),
                                              SizedBox(width: 4.0),
                                              Text(
                                                _otLibraryRecord.level,
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: _getLevelColor(
                                                      _otLibraryRecord.level),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    FutureBuilder(
                                      future: notificationService.translateText(
                                          _otLibraryRecord.description,
                                          context),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<String> snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              ShimmeringTextListWidget(
                                                  width: 400, numOfLines: 4),
                                            ],
                                          ); // or any loading indicator
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          String desc = snapshot.data!;
                                          return Text(
                                            desc,
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.grey[500]),
                                          );
                                        }
                                      },
                                    ),
                                    SizedBox(height: 250.0),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            SizedBox(height: 70),
                            Expanded(
                              child: ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  player,
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: FutureBuilder(
                                            future: notificationService
                                                .translateText(
                                                    _otLibraryRecord.title,
                                                    context),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return ShimmeringTextListWidget(
                                                    width: 300, numOfLines: 2);
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    'Error: ${snapshot.error}');
                                              } else {
                                                String title = snapshot.data!;
                                                return Text(
                                                  title,
                                                  style: TextStyle(
                                                    fontSize: 24.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color: Colors.blue[500]!,
                                                  width: 2.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.access_time,
                                                      color: Colors.blue[500]),
                                                  SizedBox(width: 4.0),
                                                  Text(
                                                    '${_otLibraryRecord.duration} ${LocaleKeys.minutes.tr()}',
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: Colors.blue[500],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 8.0),
                                            Container(
                                              padding: EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color: _getLevelColor(
                                                      _otLibraryRecord.level),
                                                  width: 2.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.directions_run,
                                                      color: _getLevelColor(
                                                          _otLibraryRecord
                                                              .level)),
                                                  SizedBox(width: 4.0),
                                                  Text(
                                                    _getLevelText(
                                                        _otLibraryRecord.level),
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: _getLevelColor(
                                                          _otLibraryRecord
                                                              .level),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        FutureBuilder(
                                          future:
                                              notificationService.translateText(
                                                  _otLibraryRecord.description,
                                                  context),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<String> snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  ShimmeringTextListWidget(
                                                      width: 400,
                                                      numOfLines: 4),
                                                ],
                                              ); // or any loading indicator
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            } else {
                                              String desc = snapshot.data!;
                                              return Text(
                                                desc,
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Colors.grey[500]),
                                              );
                                            }
                                          },
                                        ),
                                        SizedBox(height: 250.0),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Positioned(
                      top: 25,
                      right: 40,
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 35.0,
                        ),
                        onPressed: () async {
                          //deactivate();
                          _controller.pauseVideo();
                          final needUpdate = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditOTActivityScreen(
                                recordId: widget.recordId,
                              ), // Replace NextPage with your desired page
                            ),
                          );

                          if (needUpdate != null && needUpdate) {
                            setState(() {
                              _loadOTLibraryRecord();
                            });
                          }
                        },
                      ),
                    ),
                    Positioned(
                      top: 25,
                      right: 0,
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 35.0,
                        ),
                        onPressed: () {
                          //deactivate();
                          _controller.pauseVideo();
                          showDeleteConfirmationDialog(context);
                        },
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.03,
                      left: 0,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: 35.0,
                        ),
                        onPressed: () async {
                          await _controller.stopVideo();
                          //await _controller.close();
                          Navigator.of(context).pop();
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
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          // While loading, you can show a loading indicator or other widgets
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero, // Remove content padding
          titlePadding:
              EdgeInsets.fromLTRB(24, 0, 24, 0), // Adjust title padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(LocaleKeys.Delete_OT_Activity.tr()),
              IconButton(
                icon: Icon(Icons.close, color: ColorConstant.RED_BUTTON_TEXT),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ),
          content: Text(
            LocaleKeys.are_you_sure_delete_ot_activity.tr(),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              // Wrap actions in Center widget
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
                    child: Text(LocaleKeys.Yes.tr(),
                        style:
                            TextStyle(color: ColorConstant.BLUE_BUTTON_TEXT)),
                    onPressed: () async {
                      await _controller.stopVideo();
                      performDeleteLogic();
                    },
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: ColorConstant.RED_BUTTON_UNPRESSED,
                    ),
                    child: Text(LocaleKeys.No.tr(),
                        style: TextStyle(color: ColorConstant.RED_BUTTON_TEXT)),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
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

  void performDeleteLogic() {
    try {
      _otLibraryService.deleteOTLibrary(widget.recordId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.Delete_OT_Activity.tr())),
      );
      //Navigator.of(context).pop();
    } catch (error) {
      print('Error deleting occupational therapy activity: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                LocaleKeys.Occupational_therapy_activity_could_not_be_deleted)),
      );
    }
    Navigator.pop(context, true);
    Navigator.pop(context, true);
  }

  Color _getLevelColor(String level) {
    if (level == 'Advanced') {
      return Colors.red[500]!;
    } else if (level == 'Intermediate') {
      return Colors.yellow[500]!;
    } else if (level == 'Beginner') {
      return Colors.green[500]!;
    }
    // Default color if the level doesn't match the conditions
    return Colors.black;
  }

  String _getLevelText(String level) {
    if (level == 'Advanced') {
      return LocaleKeys.Advanced.tr();
    } else if (level == 'Intermediate') {
      return LocaleKeys.Intermediate.tr();
    } else if (level == 'Beginner') {
      return LocaleKeys.Beginner.tr();
    }
    return '';
  }
}
