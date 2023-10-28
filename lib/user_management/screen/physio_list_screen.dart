import 'package:flutter/material.dart';
import 'package:physio_track/constant/ColorConstant.dart';

import '../../constant/ImageConstant.dart';
import '../../profile/model/user_model.dart';
import '../service/user_management_service.dart';
import 'add_physio_screen.dart';
import 'navigation_page.dart';

class PhysioListScreen extends StatefulWidget {
  @override
  _PhysioListScreenState createState() => _PhysioListScreenState();
}

class _PhysioListScreenState extends State<PhysioListScreen> {
  UserManagementService userManagementService = UserManagementService();
  late Future<List<UserModel>>
      _physioListFuture; // Add a member variable for the future

  @override
  void initState() {
    super.initState();
    _physioListFuture =
        _fetchPhysioList(); // Initialize the future in initState
  }

  Future<List<UserModel>> _fetchPhysioList() async {
    return await userManagementService.fetchUsersByRole('physio');
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
              Text('Delete Physiotherapist'),
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
              'Are you sure to delete this physiotherapist?',
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
                      'Yes',
                      style: TextStyle(color: ColorConstant.BLUE_BUTTON_TEXT),
                    ),
                    onPressed: () async {
                      await performDeleteLogic(
                          id, context); // Wait for the deletion to complete
                      setState(() {
                        _physioListFuture =
                            _fetchPhysioList(); // Refresh the physio list
                      });
                      Navigator.pop(context);
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
                      'No',
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
        SnackBar(content: Text("Physiotherapist deleted")),
      );
    } catch (error) {
      print('Error deleting physiotherapist: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Physiotherapist could not be deleted")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: _physioListFuture, // Use the member variable for the future
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.hasData) {
          List<UserModel> physios = snapshot.data!;
          return Stack(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
              child: ListView(
                padding: EdgeInsets.zero,
                children: physios.map((UserModel user) {
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
                            subtitle: Text(user
                                .email), // Replace with the actual user name
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Container(
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors
                                  .white, // Replace with desired button color
                            ),
                            child: IconButton(
                              icon: Icon(Icons
                                  .delete_outline), // Replace with desired icon
                              color: Colors
                                  .blue, // Replace with desired icon color
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
              ),
            ),
            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () async{
                  final needUpdate = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPhysioScreen(),
                    ),
                  );
                  if (needUpdate!=null && needUpdate) {
                    setState(() {
                      _physioListFuture =
                          _fetchPhysioList(); // Refresh the physio list
                    });
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.add,
                    size: 30,
                    color: Colors.white,
                  ),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ]);
        }
        return Container(); // Return an empty container if no data is available
      },
    );
  }
}
