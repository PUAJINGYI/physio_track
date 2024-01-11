import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../constant/ColorConstant.dart';
import '../constant/ImageConstant.dart';
import '../main.dart';
import '../translations/locale_keys.g.dart';

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 150,
    height: 150,
  );
}

TextField reusableTextField(
  String text,
  String errorText,
  IconData icon,
  bool isPasswordType,
  TextEditingController controller,
  bool validate,
  bool isObsure,
  VoidCallback toggleObscure,
) {
  return TextField(
    controller: controller,
    obscureText: isObsure && isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.black,
    style: TextStyle(color: Colors.black.withOpacity(0.9)),
    decoration: isPasswordType
        ? InputDecoration(
            prefixIcon: Icon(
              icon,
              color: Colors.black,
            ),
            suffixIcon: IconButton(
                icon: Icon(isObsure ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleObscure,
                color: Colors.grey),
            labelText: text,
            errorText: validate ? errorText : null,
            labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
            filled: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            fillColor: Colors.white,
            border: UnderlineInputBorder(),
          )
        : InputDecoration(
            prefixIcon: Icon(
              icon,
              color: Colors.black,
            ),
            labelText: text,
            errorText: validate ? errorText : null,
            labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
            filled: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            fillColor: Colors.white,
            border: UnderlineInputBorder(),
          ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

Container signInSignUpButton(
    BuildContext context, bool isLogin, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        child: Text(
          isLogin ? LocaleKeys.Login.tr() : LocaleKeys.Sign_Up.tr(),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Color.fromARGB(255, 66, 157, 173);
              }
              return Color.fromARGB(255, 43, 222, 253);
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))))),
  );
}

Container signInGmailButton(BuildContext context, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Image.asset(
              ImageConstant.GOOGLE_ICON,
              height: 35.0,
              alignment: Alignment.center,
            ),
            new Container(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: new Text(
                  LocaleKeys.Google_Sign_In.tr(),
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
          ],
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.white24;
              }
              return Colors.black;
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))))),
  );
}

Container resetPasswordButton(
    BuildContext context, bool isLogin, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        child: Text(
          LocaleKeys.Reset_Password.tr(),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Color.fromARGB(255, 66, 157, 173);
              }
              return Color.fromARGB(255, 43, 222, 253);
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))))),
  );
}

Padding signOutButton(BuildContext context, Function onTap) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
      child: ElevatedButton(
          onPressed: () {
            onTap();
          },
          child: Text(
            LocaleKeys.Log_Out.tr(),
            style: const TextStyle(
                color: Color.fromRGBO(255, 0, 0, 1),
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.pressed)) {
                  return Color.fromRGBO(253, 124, 124, 1);
                }
                return Color.fromRGBO(246, 195, 195, 1);
              }),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))))),
    ),
  );
}

Padding editProfileButton(BuildContext context, Function onTap) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
      child: ElevatedButton(
          onPressed: () {
            onTap();
          },
          child: Text(
            LocaleKeys.Edit_Profile.tr(),
            style: const TextStyle(
                color: Color.fromRGBO(158, 134, 6, 1),
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.pressed)) {
                  return Color.fromRGBO(230, 199, 46, 0.784);
                }
                return Color.fromRGBO(255, 249, 132, 1);
              }),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))))),
    ),
  );
}

Padding changeLangButton(BuildContext context, Function onTap) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
      child: ElevatedButton(
          onPressed: () {
            onTap();
          },
          child: Text(
            LocaleKeys.Change_Language.tr(),
            style: const TextStyle(
                color: Color.fromRGBO(72, 208, 254, 1),
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.pressed)) {
                  return Color.fromRGBO(72, 208, 254, 0.8);
                }
                return Color.fromRGBO(174, 235, 255, 1);
              }),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))))),
    ),
  );
}

Padding infoCard(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
    child: Container(
      height: 85.0,
      child: Card(
        color: Colors.blue[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Icon(
                icon,
                size: 40.0,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 18.0,
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
}

Padding infoCardEdit(
    IconData icon, String text, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
    child: Container(
      height: 85.0,
      child: Card(
        color: Colors.blue[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Icon(
                icon,
                size: 40.0,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                      cursorColor: Colors.black,
                      controller: controller,
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.9), fontSize: 18.0),
                      decoration: InputDecoration(
                        labelText: text,
                        hintText: text,
                        labelStyle:
                            TextStyle(color: Colors.black.withOpacity(0.5)),
                        filled: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: Colors.blue[50],
                        border: UnderlineInputBorder(),
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Container changePassword(BuildContext context, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        child: Text(
          LocaleKeys.Reset_Password.tr(),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Color.fromARGB(255, 66, 157, 173);
              }
              return Color.fromARGB(255, 43, 222, 253);
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))))),
  );
}

Padding editProfileInputField(String text, String errorText, bool validate,
    TextEditingController textEditingController) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        TextField(
            cursorColor: Color.fromRGBO(0, 0, 0, 1),
            controller: textEditingController,
            style: TextStyle(
                color: Colors.black.withOpacity(0.9),
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
              filled: true,
              errorText: validate ? errorText : null,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              fillColor: Colors.white.withOpacity(0.1),
              border: UnderlineInputBorder(),
            )),
      ],
    ),
  );
}

Padding updatePrfoileButton(BuildContext context, Function onTap) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
      child: ElevatedButton(
          onPressed: () {
            onTap();
          },
          child: Text(
            LocaleKeys.Update_Profile.tr(),
            style: const TextStyle(
                color: Color.fromARGB(255, 4, 161, 51),
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.pressed)) {
                  return Color.fromARGB(255, 46, 203, 80);
                }
                return Color.fromARGB(255, 130, 241, 149);
              }),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))))),
    ),
  );
}

Container customButton(
  BuildContext context,
  String text,
  Color colorText,
  Color colorUnpressed,
  Color colorPressed,
  Function onTap,
) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return colorPressed;
          }
          return colorUnpressed;
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colorText,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );
}

GestureDetector customClickableCard(
    String title, ImageProvider<Object> imageProvider, Function() onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20), 
        child: Card(
          color: Color.fromARGB(255, 184, 216, 242),
          child: Container(
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

GestureDetector customHalfSizeCard(BuildContext context, String imagePath,
    String title, Color color, Function() onTap) {
  return GestureDetector(
    onTap: () {
      onTap();
    },
    child: Container(
      width:
          MediaQuery.of(context).size.width * 0.45, 
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0), 
        child: Card(
          elevation: 2.0,
          child: Container(
            color: color,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  width: 140,
                  height: 140,
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

GestureDetector exerciseCard(BuildContext context, double progress,
    String imagePath2, String upperText, Function() onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width:
          MediaQuery.of(context).size.width * 0.45, 
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Card(
          elevation: 2.0,
          child: Container(
            color: Colors.blue[100],
            child: Stack(
              alignment:
                  Alignment.topRight,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: Text(
                            upperText,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Center(
                        child: Image.asset(
                          imagePath2,
                          width: 150,
                          height: 100,
                        ),
                      ),
                    ),
                  
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 10, 0),
                  child: CircularPercentIndicator(
                    radius: 15,
                    lineWidth: 3.0,
                    percent: progress,
                    progressColor: Colors.blue,
                    backgroundColor: Colors.blue.shade100,
                    circularStrokeCap: CircularStrokeCap.round,
                    center: new Text(
                      "${(progress * 100).toInt().toString()}%",
                      style: new TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<dynamic> reusableDialog(context, String title, String subTitle){
  return showDialog(
    context: NavigatorKey.currentState!.overlay!.context,
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
                Text(title),
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
                subTitle,
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
}
