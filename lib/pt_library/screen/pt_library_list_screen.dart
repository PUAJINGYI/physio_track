import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/pt_library/screen/pt_library_detail_screen.dart';
import 'package:physio_track/pt_library/screen/pt_library_detail_screen.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../notification/service/notification_service.dart';
import '../../notification/widget/shimmering_text_list_widget.dart';
import '../../translations/locale_keys.g.dart';
import '../model/pt_library_model.dart';
import 'add_pt_activity_library_screen.dart';

class PTLibraryListScreen extends StatefulWidget {
  @override
  _PTLibraryListScreenState createState() => _PTLibraryListScreenState();
}

class _PTLibraryListScreenState extends State<PTLibraryListScreen> {
  final YoutubeExplode _ytExplode = YoutubeExplode();
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    setState(() {});
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
                height: 240.0,
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pt_library')
                      .orderBy('id')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(ImageConstant
                                .DATA_NOT_FOUND), // Replace 'assets/no_data_image.png' with the actual image asset path
                            Text(LocaleKeys.No_PT_Activity_Found.tr(),
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      padding: EdgeInsets.zero,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        PTLibrary ptLibrary = PTLibrary.fromSnapshot(document);
                        return GestureDetector(
                          onTap: () async {
                            final needUpdate = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PTLibraryDetailScreen(
                                  recordId: ptLibrary.id,
                                ), // Replace NextPage with your desired page
                              ),
                            );

                            if (needUpdate != null && needUpdate) {
                              setState(() {});
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Card(
                              color: Color.fromRGBO(241, 243, 250, 1),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      leading: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 5, 0, 5),
                                        child: Container(
                                          width: 80,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image:
                                                  ptLibrary.thumbnailUrl != null
                                                      ? NetworkImage(ptLibrary
                                                              .thumbnailUrl)
                                                          as ImageProvider
                                                      : AssetImage(ImageConstant
                                                              .DATA_NOT_FOUND)
                                                          as ImageProvider,
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: FutureBuilder(
                                        future:
                                            notificationService.translateText(
                                                ptLibrary.title, context),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<String> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                ShimmeringTextListWidget(
                                                    width: 300, numOfLines: 2),
                                              ],
                                            ); // or any loading indicator
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            String title = snapshot.data!;
                                            return Text(title,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500));
                                          }
                                        },
                                      ),
                                      trailing: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue,
                                        ),
                                        child: IconButton(
                                          onPressed: () async {
                                            final needUpdate =
                                                await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PTLibraryDetailScreen(
                                                  recordId: ptLibrary.id,
                                                ), // Replace NextPage with your desired page
                                              ),
                                            );

                                            if (needUpdate != null &&
                                                needUpdate) {
                                              setState(() {});
                                            }
                                          },
                                          icon: Icon(
                                            Icons.play_arrow_outlined,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 120.0,
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
                LocaleKeys.PT_Activity_Library.tr(),
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
            right: 5,
            child: Image.asset(
              ImageConstant.PT,
              width: 211.0,
              height: 169.0,
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                final needUpdate = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddPTActivityScreen(), // Replace NextPage with your desired page
                  ),
                );

                if (needUpdate != null && needUpdate) {
                  setState(() {});
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
                  color: Colors.blue, // Replace with desired button color
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
