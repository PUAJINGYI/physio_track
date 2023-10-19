import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../constant/TextConstant.dart';
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
                                      child: Text(
                                        _otLibraryRecord.title,
                                        style: TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.access_time,
                                                  color: Colors.blue[500]),
                                              SizedBox(width: 4.0),
                                              Text(
                                                '${_otLibraryRecord.duration} mins',
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
                                            color: _getLevelBackgroundColor(
                                                _otLibraryRecord.level),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
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
                                    Text(
                                      _otLibraryRecord.description,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.grey[500]),
                                    ),
                                    SizedBox(height: 250.0),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }

                        return ListView(
                          children: [
                            SizedBox(height: 40.0),
                            player,
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      _otLibraryRecord.title,
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.access_time,
                                                color: Colors.blue[500]),
                                            SizedBox(width: 4.0),
                                            Text(
                                              '${_otLibraryRecord.duration} mins',
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
                                          color: _getLevelBackgroundColor(
                                              _otLibraryRecord.level),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
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
                                  Text(
                                    _otLibraryRecord.description,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey[500]),
                                  ),
                                  SizedBox(height: 250.0),
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
                        onPressed: () {
                          //deactivate();
                          _controller.pauseVideo();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditOTActivityScreen(
                                recordId: widget.recordId,
                              ), // Replace NextPage with your desired page
                            ),
                          );
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
                          'OT Activity Library',
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
              Text('Delete OT Activity'),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ),
          content: Text(
            'Are you sure to delete this occupational therapy activity?',
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
                      backgroundColor: Color.fromRGBO(220, 241, 254, 1),
                    ),
                    child: Text('Yes',
                        style:
                            TextStyle(color: Color.fromRGBO(18, 190, 246, 1))),
                    onPressed: () {
                      _controller.close();
                      performDeleteLogic();
                      //Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Color.fromARGB(255, 237, 159, 153),
                    ),
                    child: Text('No',
                        style:
                            TextStyle(color: Color.fromARGB(255, 217, 24, 10))),
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
        SnackBar(content: Text("Occupational therapy activity be deleted")),
      );
      //Navigator.of(context).pop();
    } catch (error) {
      print('Error deleting occupational therapy activity: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Occupational therapy activity could not be deleted")),
      );
    }
    Navigator.of(context).pop();
    Navigator.of(context).pop();

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => OTLibraryListScreen(),
    //   ),
    // );
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

  Color _getLevelBackgroundColor(String level) {
    if (level == 'Advanced') {
      return Colors.red[100]!;
    } else if (level == 'Intermediate') {
      return Colors.yellow[100]!;
    } else if (level == 'Beginner') {
      return Colors.green[100]!;
    }
    // Default background color if the level doesn't match the conditions
    return Colors.grey[300]!;
  }

  Color _getCatColor(String cat) {
    if (cat == 'Lower') {
      return Colors.blue[500]!;
    } else if (cat == 'Upper') {
      return Colors.red[500]!;
    } else if (cat == 'Transfer') {
      return Colors.green[500]!;
    } else if (cat == 'Bed Mobility') {
      return Colors.purple[500]!;
    } else if (cat == 'Breathing') {
      return Colors.teal[500]!;
    } else if (cat == 'Core Movement') {
      return Colors.orange[500]!;
    } else if (cat == 'Passive Movement') {
      return Colors.grey[500]!;
    } else if (cat == 'Sitting') {
      return Colors.brown[500]!;
    } else if (cat == 'Active Assisted Movement') {
      return Colors.yellow[500]!;
    }
    // Default color if the level doesn't match the conditions
    return Colors.black;
  }

  Color _getCatBackgroundColor(String cat) {
    if (cat == 'Lower') {
      return Colors.blue[100]!;
    } else if (cat == 'Upper') {
      return Colors.red[100]!;
    } else if (cat == 'Transfer') {
      return Colors.green[100]!;
    } else if (cat == 'Bed Mobility') {
      return Colors.purple[100]!;
    } else if (cat == 'Breathing') {
      return Colors.teal[100]!;
    } else if (cat == 'Core Movement') {
      return Colors.orange[100]!;
    } else if (cat == 'Passive Movement') {
      return Colors.grey[300]!;
    } else if (cat == 'Sitting') {
      return Colors.brown[100]!;
    } else if (cat == 'Active Assisted Movement') {
      return Colors.yellow[100]!;
    }
    // Default background color if the level doesn't match the conditions
    return Colors.grey[300]!;
  }

  IconData _getCatIcon(String cat) {
    if (cat == 'Lower') {
      return Icons.airline_seat_legroom_extra_outlined;
    } else if (cat == 'Upper') {
      return Icons.back_hand_outlined;
    } else if (cat == 'Transfer') {
      return Icons.transfer_within_a_station_outlined;
    } else if (cat == 'Bed Mobility') {
      return Icons.hotel;
    } else if (cat == 'Breathing') {
      return Icons.air_outlined;
    } else if (cat == 'Core Movement') {
      return Icons.accessibility_new_outlined;
    } else if (cat == 'Passive Movement') {
      return Icons.blind_outlined;
    } else if (cat == 'Sitting') {
      return Icons.event_seat_outlined;
    } else if (cat == 'Active Assisted Movement') {
      return Icons.directions_walk_outlined;
    }
    // Default background color if the level doesn't match the conditions
    return Icons.question_mark_outlined;
  }

  String _getCatText(String cat) {
    if (cat == 'Lower') {
      return 'Lower';
    } else if (cat == 'Upper') {
      return 'Upper';
    } else if (cat == 'Transfer') {
      return 'Transfer';
    } else if (cat == 'Bed Mobility') {
      return 'Bed';
    } else if (cat == 'Breathing') {
      return 'Breathing';
    } else if (cat == 'Core Movement') {
      return 'Core';
    } else if (cat == 'Passive Movement') {
      return 'Passive';
    } else if (cat == 'Sitting') {
      return 'Sitting';
    } else if (cat == 'Active Assisted Movement') {
      return 'Active';
    }
    return '';
  }
}
