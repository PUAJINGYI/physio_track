import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/achievement/screen/physio/patient_details_screen.dart';
import 'package:physio_track/user_management/service/user_management_service.dart';

import '../../../constant/ImageConstant.dart';
import '../../../constant/TextConstant.dart';
import '../../../profile/model/user_model.dart';
import '../../../translations/locale_keys.g.dart';

class PatientListByPhysioScreen extends StatefulWidget {
  const PatientListByPhysioScreen({super.key});

  @override
  State<PatientListByPhysioScreen> createState() =>
      _PatientListByPhysioScreenState();
}

class _PatientListByPhysioScreenState extends State<PatientListByPhysioScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  UserManagementService userManagementService = UserManagementService();
  late List<UserModel> patientListUnderPhysio;

  Future<List<UserModel>> getPatientList() async {
    int id = await userManagementService.fetchUserIdByUid(uid);
    patientListUnderPhysio =
        await userManagementService.fetchPatientByPhysioId(id);
    return patientListUnderPhysio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 210.0,
              ),
              Expanded(
                child: FutureBuilder<List<UserModel>>(
                  future: getPatientList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('${LocaleKeys.Error.tr()}: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      List<UserModel> patients = snapshot.data!;

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, 
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                          ),
                          itemCount: patients.length,
                          itemBuilder: (context, index) {
                            UserModel patient = patients[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PatientDetailsScreen(
                                        patientId: patient.id),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Card(
                                  color: Colors.grey[100],
                                  elevation: 1.0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 40.0,
                                        backgroundImage:
                                            patient.profileImageUrl == null ||
                                                    patient.profileImageUrl ==
                                                        ''
                                                ? AssetImage(
                                                    ImageConstant.DEFAULT_USER)
                                                : NetworkImage(
                                                        patient.profileImageUrl)
                                                    as ImageProvider<Object>?,
                                        backgroundColor: Colors.grey,
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        patient.username,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100.0,
                              height: 100.0,
                              child: Image.asset(ImageConstant.DATA_NOT_FOUND),
                            ),
                            Text(LocaleKeys.No_Patient_Available.tr(),
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: 25,
            left: 0,
            right: 0,
            child: Container(
              height: kToolbarHeight,
              alignment: Alignment.center,
              child: Text(
                LocaleKeys.Patient_List.tr(),
                style: TextStyle(
                  fontSize: TextConstant.TITLE_FONT_SIZE,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 55,
            right: 0,
            left: 0,
            child: Image.asset(
              ImageConstant.PATIENT_LIST,
              width: 261.0,
              height: 190.0,
            ),
          ),
        ],
      ),
    );
  }
}
