import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

import 'chat.dart';
import 'diary_entry.dart';
import 'helpline.dart';
import 'profile.dart';
import 'tracker.dart';
import 'youtube.dart';
import 'authentication/login.dart';

class ContainerScreen extends StatefulWidget {
  const ContainerScreen({super.key});

  @override
  State<ContainerScreen> createState() => _ContainerScreenState();
}

class _ContainerScreenState extends State<ContainerScreen> {
  String userName = "User"; // Default username, will update with actual name.

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data from Firestore on screen load
  }

  // Fetch user data from Firestore
  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data();
          if (data != null) {
            setState(() {
              userName = "${data['firstName']}"; // Fetch first name
            });
          }
        } else {
          print("No such document in Firestore.");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  // Sign out user
  Future<void> signOutUser() async {
    await FirebaseAuth.instance.signOut().then((value) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false);
    });
  }

  // Build card button with larger image
  Widget _buildCardButton(BuildContext context, String title, String imagePath,
      Widget? destination) {
    return Card(
      elevation: 8, // Increased shadow elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Rounded corners
      ),
      color: Colors.white, // Card color
      shadowColor: Colors.grey.withOpacity(0.5), // Shadow color
      child: InkWell(
        borderRadius:
            BorderRadius.circular(20.0), // Rounded corners for ripple effect
        onTap: () {
          if (title == 'PHQ-9 Test') {
            _launchURL('http://127.0.0.1:5000/'); // Launch URL for PHQ-9 Test
          } else if (title == 'Audio Emotion Detection') {
            _launchURL(
                'https://example.com/audio-emotion-detection'); // Replace with actual URL
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination!),
            );
          }
        },
        child: Padding(
          padding:
              const EdgeInsets.all(20.0), // Increased padding inside the card
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the image directly without circular clipping
              Image.asset(
                imagePath, // Path to your image
                width: 100, // Increased width of the image
                height: 100, // Increased height of the image
                fit: BoxFit.cover, // Cover the entire area
              ),
              const SizedBox(height: 10), // Space between image and title
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // Increased title font size
                  color: Colors.blue, // Change text color here
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to launch the URL
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: signOutUser,
        child: const Icon(Icons.logout_sharp),
      ),
      body: Container(
        color: const Color(0xFFFFF8DB), // Set background color
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileSection(
                  context), // Profile section with user details
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 1 / 1.2, // Adjust aspect ratio for height
                  children: <Widget>[
                    _buildCardButton(context, 'Chat with Dawn',
                        'assets/chat.png', ChatPage()), // Update image path
                    _buildCardButton(
                        context,
                        'Diary Analysis',
                        'assets/diary.png',
                        DiaryEntryScreen()), // Update image path
                    _buildCardButton(context, 'PHQ-9 Test', 'assets/phq.png',
                        null), // Update image path
                    /*_buildCardButton(context, 'Audio Emotion Detection',
                        'assets/speech.png', null), // Update image path*/
                    _buildCardButton(context, 'Helpline Numbers',
                        'assets/help.png', Helpline()), // Update image path
                    _buildCardButton(context, 'Tracker', 'assets/routine.png',
                        TrackerPage()), // Update image path
                    _buildCardButton(context, 'Exercises', 'assets/yoga.png',
                        YouTubeScreen()), // Update image path
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Profile section with clickable navigation to ProfilePage
  Widget _buildProfileSection(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfilePage(testName: 'Bipolar Test')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          // Remove or comment out the background color property
          // color: Colors.purple.shade50, // Removed background color of profile section
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.transparent, // Shadow color
              blurRadius: 5.0,
              spreadRadius: 2.0,
              offset: const Offset(0, 3), // Shadow position
            ),
          ],
        ),
        child: Row(
          children: [
            // Person icon
            const Icon(
              Icons.person,
              size: 60, // Increased size of the icon
              color: Colors.blue, // Customize the color
            ),
            const SizedBox(width: 10), // Space between icon and text
            // Column for greeting and description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display "Hi, username"
                Text(
                  'Hi, ${userName[0].toUpperCase()}${userName.substring(1)}!', // Greet the user with their name
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 5), // Small space between the texts
                // Display description
                const Text(
                  'Track your health effortlessly', // Add description
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(137, 0, 0, 0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
