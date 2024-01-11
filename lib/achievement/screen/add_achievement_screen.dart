import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constant/ColorConstant.dart';
import '../../translations/locale_keys.g.dart';
import '../model/achievement_model.dart';
import '../service/achievement_service.dart';

class AddAchievementScreen extends StatefulWidget {
  @override
  _AddAchievementScreenState createState() => _AddAchievementScreenState();
}

class _AddAchievementScreenState extends State<AddAchievementScreen> {
  AchievementService _achievementService = AchievementService();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String imageUrl = '';
  File? imageFile; 

  final picker = ImagePicker();

  Future<void> _uploadImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveAchievement() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        imageFile == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero, 
            titlePadding:
                EdgeInsets.fromLTRB(16, 0, 16, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(LocaleKeys.Error.tr()),
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
                'Please enter a title, description, and select an image.',
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
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('achievements/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await storageReference.putFile(imageFile!);
    imageUrl = await storageReference.getDownloadURL();

    int latestId = 1;

    final Achievement achievement = Achievement(
      id: latestId,
      title: titleController.text,
      description: descriptionController.text,
      imageUrl: imageUrl,
    );

    _achievementService.addArchievementRecord(achievement);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocaleKeys.New_Achievement_Record_Added.tr()),
        duration: Duration(seconds: 3),
      ),
    );

    titleController.clear();
    descriptionController.clear();
    setState(() {
      imageFile = null;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievement Entry'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('Select Image'),
              ),
              SizedBox(height: 16.0),
              imageFile != null ? Image.file(imageFile!) : Container(),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveAchievement,
                child: Text('Save Achievement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
