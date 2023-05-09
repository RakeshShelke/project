import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_chat_app/helper/helperFunction.dart';
import 'package:firebase_chat_app/pages/auth/loginPage.dart';
import 'package:firebase_chat_app/pages/homePage.dart';
import 'package:firebase_chat_app/shared/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
   await Firebase.initializeApp(
        options: FirebaseOptions(
      apiKey: Constant.apiKey,
      appId: Constant.appId,
      messagingSenderId: Constant.messagingSenderId,
      authDomain: Constant.authDomain,
      measurementId: Constant.measurementId, projectId: Constant.projectId,
    ));
  } else {
    await Firebase.initializeApp();
  }
  runApp(const ChatApp());
}

class ChatApp extends StatefulWidget {
  const ChatApp({Key? key}) : super(key: key);

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  bool _isSignIn = false;

  @override
  void initState() {
    super.initState();
    getUserStatus();
  }

  getUserStatus() async {
    await HelperFunction.getUserLogged().then((value) {
      if (value != null) {
        setState(() {
          _isSignIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(primaryColor: Constant().primaryColor),
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
          splash: Image.asset('assets/flutter.jpg'),
          duration: 3000,
          splashTransition: SplashTransition.rotationTransition,
          backgroundColor: Colors.white,
          nextScreen: _isSignIn ? const HomePage() : const LoginPage()),
    );
  }
}
