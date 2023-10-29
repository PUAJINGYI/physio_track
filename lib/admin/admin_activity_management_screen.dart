import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/pt_library/screen/pt_library_list_screen.dart';

import '../constant/ImageConstant.dart';
import '../constant/TextConstant.dart';
import '../ot_library/screen/ot_library_list_screen.dart';
import '../translations/locale_keys.g.dart';

class AdminActivityManagementScreen extends StatefulWidget {
  const AdminActivityManagementScreen({super.key});

  @override
  State<AdminActivityManagementScreen> createState() =>
      _AdminActivityManagementScreenState();
}

class _AdminActivityManagementScreenState
    extends State<AdminActivityManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 250,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(15.0), // Adjust the radius as needed
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PTLibraryListScreen()),
                    );
                  },
                  child: Card(
                    elevation: 5.0,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            LocaleKeys.PT.tr(),
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Image.asset(
                            ImageConstant.PT,
                            width: 211.0,
                            height: 169.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(15.0), // Adjust the radius as needed
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OTLibraryListScreen()),
                    );
                  },
                  child: Card(
                    elevation: 5.0,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            LocaleKeys.OT.tr(),
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Image.asset(
                            ImageConstant.OT,
                            width: 211.0,
                            height: 169.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
              LocaleKeys.Activity_Management.tr(),
              style: TextStyle(
                fontSize: TextConstant.TITLE_FONT_SIZE,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Image.asset(
            ImageConstant.PHYSIO_HOME,
            width: 211.0,
            height: 169.0,
          ),
        ),
      ],
    ));
  }
}
