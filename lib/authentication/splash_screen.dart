import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/authentication/redirect_screen.dart';
import 'package:physio_track/authentication/service/auth_manager.dart';
import 'package:physio_track/authentication/signin_screen.dart';

import '../constant/ImageConstant.dart';
import '../notification/notification_services.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  NotificationServices notificationServices = NotificationServices();
  //AuthManager authManager = AuthManager();
  var auth = FirebaseAuth.instance;
  var isLogin = false;

  @override
  void initState() {
    checkIfLogin();
    super.initState();

    notificationServices.requestNotificationPermission();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();

    notificationServices.getDeviceToken().then((value) {
      if (kDebugMode) {
        print('device token');
        print(value);
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..forward();

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Simulate an asynchronous operation (e.g., loading data) here
    //bool loginStatus = authManager.isLoggedIn;
    checkIfLogin();
    print('loginStatus: ${isLogin}');
    Future.delayed(Duration(seconds: 3), () async {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => isLogin ? RedirectScreen() : SignInScreen()),
      );
    });
  }

  checkIfLogin() async {
    auth.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        setState(() {
          isLogin = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(ImageConstant.LOGO),
              SizedBox(height: 16),
              Text(
                'PhysioTrack',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
