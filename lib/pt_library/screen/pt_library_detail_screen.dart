import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../constant/TextConstant.dart';
import '../../notification/widget/shimmering_text_list_widget.dart';
import '../../reusable_widget/reusable_widget.dart';
import '../../translations/locale_keys.g.dart';
import '../../translations/service/translate_service.dart';
import '../model/pt_library_model.dart';
import '../service/pt_library_service.dart';
import 'edit_pt_activity_library.dart';

class PTLibraryDetailScreen extends StatefulWidget {
  final int recordId;
  PTLibraryDetailScreen({required this.recordId});

  @override
  _PTLibraryDetailScreenState createState() => _PTLibraryDetailScreenState();
}

class _PTLibraryDetailScreenState extends State<PTLibraryDetailScreen> {
  late PTLibrary _ptLibraryRecord;
  final PTLibraryService _ptLibraryService = PTLibraryService();
  late YoutubePlayerController _controller;
  TranslateService translateService = TranslateService();
  Future<void> _loadPTLibraryRecord() async {
    try {
      _ptLibraryRecord =
          (await _ptLibraryService.fetchPTLibrary(widget.recordId))!;
    } catch (e) {
      print('Error fetching PTLibrary record: $e');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  String extractVideoIdFromUrl(String url) {
    RegExp regExp = RegExp(
      r"(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})",
    );
    RegExpMatch? match = regExp.firstMatch(url);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)!; 
    }

    return ""; 
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadPTLibraryRecord(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final videoUrl = _ptLibraryRecord.videoUrl;
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
                                            translateService.translateText(
                                                _ptLibraryRecord.title,
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
                                                '${_ptLibraryRecord.duration} mins',
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
                                                  _ptLibraryRecord.level),
                                              width: 2.0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.directions_run,
                                                  color: _getLevelColor(
                                                      _ptLibraryRecord.level)),
                                              SizedBox(width: 4.0),
                                              Text(
                                                _ptLibraryRecord.level,
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: _getLevelColor(
                                                      _ptLibraryRecord.level),
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
                                              color: _getCatColor(
                                                  _ptLibraryRecord.cat),
                                              width: 2.0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                  _getCatIcon(
                                                      _ptLibraryRecord.cat),
                                                  color: _getCatColor(
                                                      _ptLibraryRecord.cat)),
                                              SizedBox(width: 4.0),
                                              Text(
                                                _getCatText(
                                                    _ptLibraryRecord.cat),
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: _getCatColor(
                                                      _ptLibraryRecord.cat),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    FutureBuilder(
                                      future: translateService.translateText(
                                          _ptLibraryRecord.description,
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
                                          ); 
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
                                            future: translateService
                                                .translateText(
                                                    _ptLibraryRecord.title,
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
                                                    '${_ptLibraryRecord.duration} ${LocaleKeys.minutes.tr()}',
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
                                                      _ptLibraryRecord.level),
                                                  width: 2.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.directions_run,
                                                      color: _getLevelColor(
                                                          _ptLibraryRecord
                                                              .level)),
                                                  SizedBox(width: 4.0),
                                                  Text(
                                                    _getLevelText(
                                                        _ptLibraryRecord.level),
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: _getLevelColor(
                                                          _ptLibraryRecord
                                                              .level),
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
                                                  color: _getCatColor(
                                                      _ptLibraryRecord.cat),
                                                  width: 2.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                      _getCatIcon(
                                                          _ptLibraryRecord.cat),
                                                      color: _getCatColor(
                                                          _ptLibraryRecord
                                                              .cat)),
                                                  SizedBox(width: 4.0),
                                                  Text(
                                                    _getCatText(
                                                        _ptLibraryRecord.cat),
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: _getCatColor(
                                                          _ptLibraryRecord.cat),
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
                                              translateService.translateText(
                                                  _ptLibraryRecord.description,
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
                                              ); 
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
                          _controller.pauseVideo();
                          final needUpdate = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPTActivityScreen(
                                recordId: widget.recordId,
                              ), 
                            ),
                          );

                          if (needUpdate != null && needUpdate) {
                            setState(() {
                              _loadPTLibraryRecord();
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
                          _controller.pauseVideo();
                          showDeleteConfirmationDialog(context);
                        },
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
                        onPressed: () async {
                          await _controller.stopVideo();
                          Navigator.pop(context, true);
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
          contentPadding: EdgeInsets.zero, 
          titlePadding:
              EdgeInsets.fromLTRB(24, 0, 24, 0), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(LocaleKeys.Delete_PT_Activity.tr()),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop(); 
                },
              ),
            ],
          ),
          content: Text(
            LocaleKeys.are_you_sure_delete_pt_activity.tr(),
            textAlign: TextAlign.center,
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
                      backgroundColor: Color.fromRGBO(220, 241, 254, 1),
                    ),
                    child: Text(LocaleKeys.Yes.tr(),
                        style:
                            TextStyle(color: Color.fromRGBO(18, 190, 246, 1))),
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
                      backgroundColor: Color.fromARGB(255, 237, 159, 153),
                    ),
                    child: Text(LocaleKeys.No.tr(),
                        style:
                            TextStyle(color: Color.fromARGB(255, 217, 24, 10))),
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

  void performDeleteLogic() {
    try {
      _ptLibraryService.deletePTLibrary(widget.recordId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.Delete_PT_Activity.tr())),
      );
    } catch (error) {
      print('Error deleting occupational therapy activity: $error');
      reusableDialog(context, LocaleKeys.Error.tr(),
          LocaleKeys.Physiotherapy_activity_could_not_be_deleted.tr());
    }
    Navigator.pop(context, true);
    Navigator.pop(context, true);
  }

  Color _getLevelColor(String level) {
    if (level == 'Advanced') {
      return Colors.red[500]!;
    } else if (level == 'Intermediate') {
      return Colors.orange[500]!;
    } else if (level == 'Beginner') {
      return Colors.green[500]!;
    }
    return Colors.black;
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
      return Colors.yellow[600]!;
    }
    return Colors.black;
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
    return Icons.question_mark_outlined;
  }

  String _getCatText(String cat) {
    if (cat == 'Lower') {
      return LocaleKeys.Lower.tr();
    } else if (cat == 'Upper') {
      return LocaleKeys.Upper.tr();
    } else if (cat == 'Transfer') {
      return LocaleKeys.Transfer.tr();
    } else if (cat == 'Bed Mobility') {
      return LocaleKeys.Bed_Mobility.tr();
    } else if (cat == 'Breathing') {
      return LocaleKeys.Breathing.tr();
    } else if (cat == 'Core Movement') {
      return LocaleKeys.Core.tr();
    } else if (cat == 'Passive Movement') {
      return LocaleKeys.Passive.tr();
    } else if (cat == 'Sitting') {
      return LocaleKeys.Sitting.tr();
    } else if (cat == 'Active Assisted Movement') {
      return LocaleKeys.Active.tr();
    }
    return '';
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
