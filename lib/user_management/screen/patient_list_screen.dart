import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../profile/model/user_model.dart';
import '../../translations/locale_keys.g.dart';
import '../service/user_management_service.dart';
import 'navigation_page.dart';

class PatientListScreen extends StatefulWidget {
  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  UserManagementService userManagementService = UserManagementService();
  late Future<List<UserModel>>
      _patientListFuture; // Add a member variable for the future

  @override
  void initState() {
    super.initState();
    _patientListFuture =
        _fetchPatientList(); // Initialize the future in initState
  }

  Future<List<UserModel>> _fetchPatientList() async {
    return await userManagementService.fetchUsersByRole('patient');
  }

  void showDeleteConfirmationDialog(BuildContext context, int id) async {
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
              Text(LocaleKeys.Delete_Patient.tr()),
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
              LocaleKeys.are_you_sure_delete_patient.tr(),
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
                    child: Text(
                      LocaleKeys.Yes.tr(),
                      style: TextStyle(color: ColorConstant.BLUE_BUTTON_TEXT),
                    ),
                    onPressed: () async {
                      await performDeleteLogic(
                          id, context); // Wait for the deletion to complete
                      setState(() {
                        _patientListFuture =
                            _fetchPatientList(); // Refresh the patient list
                      });
                      Navigator.of(context).pop(); // Close the dialog
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
                    child: Text(
                      LocaleKeys.No.tr(),
                      style: TextStyle(color: ColorConstant.RED_BUTTON_TEXT),
                    ),
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

  Future<void> performDeleteLogic(int id, context) async {
    try {
      await userManagementService
          .deleteUser(id); // Wait for the deletion to complete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.Patient_deleted.tr())),
      );
    } catch (error) {
      print('Error deleting patient: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.Patient_could_not_be_deleted.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: _patientListFuture, // Use the member variable for the future
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('${LocaleKeys.Error.tr()}: ${snapshot.error}'));
        }
        if (snapshot.hasData) {
          List<UserModel> patients = snapshot.data!;
          return ListView(
            padding: EdgeInsets.zero,
            children: patients.map((UserModel user) {
              return Card(
                color: Color.fromRGBO(241, 243, 250, 1),
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30.0,
                          backgroundImage: user.profileImageUrl.isNotEmpty
                              ? NetworkImage(user.profileImageUrl)
                                  as ImageProvider
                              : AssetImage(ImageConstant.DEFAULT_USER)
                                  as ImageProvider,
                          backgroundColor: Colors.transparent,
                          child: user.profileImageUrl.isEmpty
                              ? Image.asset(
                                  ImageConstant
                                      .DEFAULT_USER, // Replace with the default image path
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        title: Text(user.username,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            user.email), // Replace with the actual user name
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              Colors.white, // Replace with desired button color
                        ),
                        child: IconButton(
                          icon: Icon(Icons
                              .delete_outline), // Replace with desired icon
                          color: Colors.blue, // Replace with desired icon color
                          onPressed: () {
                            showDeleteConfirmationDialog(context, user.id);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }
        return Container(); // Return an empty container if no data is available
      },
    );
  }
}
