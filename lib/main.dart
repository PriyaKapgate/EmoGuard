import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:emo_guard/container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emo_guard/authentication/login.dart';
import 'package:emo_guard/authentication/reg.dart';
import 'ondoardingScreens/firstpage.dart'; // Import FirstPage
import 'package:emo_guard/splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyCI9BhE5SVkRdoVs_eMqt-2PanwGilXIwY',
      appId: '1:209360868268:android:1c64ca66c7873ec84c6009',
      messagingSenderId: '209360868268',
      projectId: 'emogurd',
      storageBucket: 'emogurd.appspot.com',
    ),
  );

  // Check if user is logged in
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

  // Run the app
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MIND AID',
      theme: ThemeData.dark(),
      home: SplashScreen(
          isLoggedIn: isLoggedIn), // Pass login state to SplashScreen
      routes: {
        '/container': (context) => ContainerScreen(),
        '/login': (context) => LoginScreen(),
        '/registration': (context) => RegistrationScreen(),
        '/firstpage': (context) => FirstPage(),
      },
    );
  }
}
