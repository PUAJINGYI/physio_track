import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:physio_track/ot_library/service/ot_library_service.dart';

import '../model/ot_library_model.dart';

class OTLibraryDetailScreen extends StatefulWidget {
  final int recordId;

  OTLibraryDetailScreen({required this.recordId});

  @override
  State<OTLibraryDetailScreen> createState() => _OTLibraryDetailScreenState();
}

class _OTLibraryDetailScreenState extends State<OTLibraryDetailScreen> {
  List<OTLibrary> _otLibraryRecords = [];
  final OTLibraryService _otLibraryService = OTLibraryService();
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _loadOTLibraryRecord();
  }

  Future<void> _loadOTLibraryRecord() async {
    try {
      _otLibraryRecords =
          await _otLibraryService.fetchOTLibrary(widget.recordId);
      setState(() {
        _controller = YoutubePlayerController(
          initialVideoId: _otLibraryRecords.first.videoUrl,
          flags: YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            isLive: false,
          ),
        );
      });
    } catch (e) {
      // Handle error if the record could not be fetched
      print('Error fetching OTLibrary record: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTLibrary Detail'),
      ),
      body: _otLibraryRecords.isNotEmpty
          ? _buildOTLibraryDetail()
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildOTLibraryDetail() {
    final OTLibrary _otLibraryRecord = _otLibraryRecords.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        YoutubePlayer(
          controller: _controller!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          progressColors: ProgressBarColors(
            playedColor: Colors.red,
            handleColor: Colors.redAccent,
          ),
        ),
        SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _otLibraryRecord.title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                _otLibraryRecord.description,
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 8.0),
              Text(
                'Duration: ${_otLibraryRecord.duration} minutes',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 8.0),
              Text(
                'Level: ${_otLibraryRecord.level}',
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
