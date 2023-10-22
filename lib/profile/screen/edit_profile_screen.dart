import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:physio_track/profile/screen/profile_screen.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../reusable_widget/reusable_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late Map<String, dynamic> userData = {};
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  bool _validateUsernameInput = false;
  bool _validateEmailInput = false;
  bool _validatePhoneInput = false;
  bool _validateAddressInput = false;
  String uId = FirebaseAuth.instance.currentUser!.uid;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    getUserData(uId);
  }

  Future<void> getUserData(String uId) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(uId);
    DocumentSnapshot userSnapshot = await userRef.get();

    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>;
    if (userData == null) {
      print("empty");
    } else {
      setState(() {
        this.userData = userData;
        _usernameController = TextEditingController(text: userData['username']);
        _emailController = TextEditingController(text: userData['email']);
        _phoneController = TextEditingController(text: userData['phone']);
        _addressController = TextEditingController(text: userData['address']);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  // Future<void> _uploadImage() async {
  //   if (_profileImage == null) return;

  //   final storage = FirebaseStorage.instance;
  //   final storageRef = storage.ref();
  //   final userId = FirebaseAuth.instance.currentUser!.uid;
  //   final profileImageRef = storageRef.child('profile_images/$userId.jpg');

  //   await profileImageRef.putFile(_profileImage!);

  //   final imageUrl = await profileImageRef.getDownloadURL();
  //   // Save the image URL to Firestore or perform any necessary actions
  //   await FirebaseFirestore.instance.collection('users').doc(userId).update({
  //     'profileImageUrl': imageUrl,
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    if (userData.isEmpty) {
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
                  'Profile',
                  style: TextStyle(
                    fontSize: TextConstant.TITLE_FONT_SIZE,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Stack(
          children: [
            ListView(
              children: [
                SizedBox(height: 50),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 20, left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 75,
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                        as ImageProvider<Object>?
                                    : userData['profileImageUrl'] != null &&
                                            userData['profileImageUrl'] != ''
                                        ? NetworkImage(
                                                userData['profileImageUrl'])
                                            as ImageProvider<Object>?
                                        : AssetImage(
                                            ImageConstant.DEFAULT_USER),
                                backgroundColor: Colors.grey,
                              ),
                              if (userData['profileImageUrl'] == null)
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue),
                                ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.withOpacity(0.6),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: AutoSizeText(
                              userData['username'],
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              minFontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 50),
                editProfileInputField('Username:', 'Please insert username !',
                    _validateUsernameInput, _usernameController),
                SizedBox(height: 20),
                editProfileInputField(
                    'Telephone Number:',
                    'Please insert phone number !',
                    _validatePhoneInput,
                    _phoneController),
                SizedBox(height: 20),
                editProfileInputField('Email Address:', 'Please insert email !',
                    _validateEmailInput, _emailController),
                SizedBox(height: 20),
                editProfileInputField(
                    'Home Address:',
                    'Please insert address !',
                    _validateAddressInput,
                    _addressController),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: customButton(
                      context,
                      'Update Profile',
                      ColorConstant.GREEN_BUTTON_TEXT,
                      ColorConstant.GREEN_BUTTON_UNPRESSED,
                      ColorConstant.GREEN_BUTTON_PRESSED, () {
                    setState(() {
                      _usernameController.text.isEmpty
                          ? _validateUsernameInput = true
                          : _validateUsernameInput = false;
                      _phoneController.text.isEmpty
                          ? _validatePhoneInput = true
                          : _validatePhoneInput = false;
                      _emailController.text.isEmpty ||
                              !_emailController.text.contains("@")
                          ? _validateEmailInput = true
                          : _validateEmailInput = false;
                      _addressController.text.isEmpty
                          ? _validateAddressInput = true
                          : _validateAddressInput = false;
                    });
                    if (_validateUsernameInput == false &&
                        _validatePhoneInput == false &&
                        _validateEmailInput == false &&
                        _validateAddressInput == false) {
                      updateProfile(
                          _usernameController.text,
                          _phoneController.text,
                          _emailController.text,
                          _addressController.text);
                    }
                  }),
                )
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
                  'Profile',
                  style: TextStyle(
                    fontSize: TextConstant.TITLE_FONT_SIZE,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> updateProfile(
      String username, String phoneNo, String email, String address) async {
    String userId = uId;
    final imageUrl;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentSnapshot userSnapshot = await userRef.get();

    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;
    if (userData != null) {
      // Update the password field with the new password
      await userRef.update({
        'username': username,
        'phone': phoneNo,
        'email': email,
        'address': address
      });

      // Display a success message or perform any other necessary actions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (context) => ProfileScreen()));

      if (_profileImage != null) {
        final storage = FirebaseStorage.instance;
        final storageRef = storage.ref();
        final userId = FirebaseAuth.instance.currentUser!.uid;
        final profileImageRef = storageRef.child('profile_images/$userId.jpg');

        await profileImageRef.putFile(_profileImage!);

        imageUrl = await profileImageRef.getDownloadURL();
        // Save the image URL to Firestore or perform any necessary actions
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'profileImageUrl': imageUrl,
        });
        
      }
     Navigator.pop(context, true);
    }
  }
}
