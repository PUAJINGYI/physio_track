import 'dart:io'; // Import 'dart:io' for File
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  File? imageFile; // Store the picked image file

  final picker = ImagePicker();

  Future<void> _uploadImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        // Store the picked image file
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveAchievement() async {
    // Validate that both title, description, and image are entered
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        imageFile == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero, // Remove content padding
            titlePadding:
                EdgeInsets.fromLTRB(16, 0, 16, 0), // Adjust title padding
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
                    Navigator.of(context).pop(); // Close the dialog
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

    // Upload the image to Firebase Storage
    // final userId = FirebaseAuth.instance.currentUser!.uid;
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('achievements/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await storageReference.putFile(imageFile!);
    imageUrl = await storageReference.getDownloadURL();

    // Get the latest achievement ID from Firestore
    int latestId = 1; // Default to 1 if no records exist

    // QuerySnapshot achievementSnapshot = await FirebaseFirestore.instance
    //     .collection('achievements')
    //     .orderBy('id', descending: true)
    //     .limit(1)
    //     .get();
    // if (achievementSnapshot.docs.isNotEmpty) {
    //   latestId = achievementSnapshot.docs[0].get('id') + 1;
    // }

    // Create an Achievement object with the latest ID
    final Achievement achievement = Achievement(
      id: latestId,
      title: titleController.text,
      description: descriptionController.text,
      imageUrl: imageUrl,
    );

    // Store the achievement record in Firestore
    // await FirebaseFirestore.instance
    //     .collection('achievements')
    //     .add(achievement.toMap());
    _achievementService.addArchievementRecord(achievement);
    // Show a snackbar to confirm the addition
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocaleKeys.New_Achievement_Record_Added.tr()),
        duration: Duration(seconds: 3),
      ),
    );

    // Reset fields and image after adding the record
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
              // Display the picked image file if available
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
