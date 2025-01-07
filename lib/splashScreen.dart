import 'package:flutter/material.dart';
import 'package:emo_guard/container.dart';
import 'package:emo_guard/authentication/login.dart';

class SplashScreen extends StatefulWidget {
  final bool isLoggedIn;

  SplashScreen({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for 3 seconds, then navigate to the appropriate screen
    Future.delayed(Duration(seconds: 3), () {
      if (widget.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ContainerScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF), // Light gray background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 300, height: 300), // Logo
          ],
        ),
      ),
    );
  }
}
