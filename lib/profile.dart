import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emo_guard/container.dart';
import 'dart:math'; // For OTP generation
import 'package:fluttertoast/fluttertoast.dart'; // For displaying OTP sent toast

class ProfilePage extends StatefulWidget {
  final String testName;

  ProfilePage({required this.testName});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isEditing = false; // Flag to control editing state
  bool _isOtpSent = false; // Flag to indicate if OTP is sent
  String _generatedOtp = ''; // Store generated OTP

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile Page',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          centerTitle: true,
          backgroundColor: const Color(0xFFFFF9C4),
        ),
        body: const Center(
          child: Text('User not logged in.',
              style: TextStyle(color: Colors.black)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFF9C4),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('Users').doc(user.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Error fetching user data: ${snapshot.error}');
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.black)));
          }

          Map<String, dynamic>? data =
              snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return const Center(
                child: Text('No data found.',
                    style: TextStyle(color: Colors.black)));
          }

          String email = data['email'] ?? 'No email available';
          String firstName = data['firstName'] ?? 'No first name available';
          String lastName = data['lastName'] ?? 'No last name available';

          // Initialize the text controllers with fetched data
          _firstNameController.text = firstName;
          _lastNameController.text = lastName;
          _emailController.text = email;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Profile image with initials
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Color.fromARGB(255, 97, 0, 0),
                  foregroundColor: Colors.white,
                  child: Center(
                    child: Text(firstName[0],
                        style: TextStyle(
                            fontSize: 55, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),

                // Editable fields with black text
                _buildEditableField('First Name', _firstNameController),
                _buildEditableField('Last Name', _lastNameController),
                _buildEditableField('Email', _emailController),

                const SizedBox(height: 20),

                if (_isOtpSent)
                  _buildOtpField(), // Show OTP input if OTP is sent

                ElevatedButton(
                  onPressed: _isEditing
                      ? () {
                          if (_isOtpSent) {
                            _verifyOtp(user.uid); // Verify OTP and update email
                          } else {
                            _sendOtp(); // Send OTP to the email
                          }
                        }
                      : () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                  child: Text(_isEditing
                      ? (_isOtpSent ? 'Verify OTP & Save' : 'Send OTP')
                      : 'Edit Profile'),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ContainerScreen()),
                    );
                  },
                  child: const Text('Home'),
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.white,
    );
  }

  // Method to build editable text fields with black text
  Widget _buildEditableField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: _isEditing, // Enable only if in editing mode
          style: const TextStyle(color: Colors.black), // Black input text
          decoration: InputDecoration(
            border: _isEditing
                ? OutlineInputBorder()
                : InputBorder.none, // Remove border if not editing
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // OTP input field
  Widget _buildOtpField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter OTP:',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _otpController,
          style: const TextStyle(color: Colors.black), // Black input text
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // Method to generate and send OTP to the user's email
  void _sendOtp() {
    // Generate a random 6-digit OTP
    Random random = Random();
    _generatedOtp = (100000 + random.nextInt(900000)).toString();

    // Send the OTP via email (here you would use an email service like Firebase Functions, SendGrid, etc.)
    Fluttertoast.showToast(
        msg: 'OTP sent to ${_emailController.text}'); // For now, show as toast
    setState(() {
      _isOtpSent = true;
    });
  }

  // Method to verify OTP and update email
  void _verifyOtp(String uid) {
    if (_otpController.text == _generatedOtp) {
      // Update email in Firestore
      _saveChanges(uid);
    } else {
      Fluttertoast.showToast(msg: 'Invalid OTP');
    }
  }

  // Method to save changes to Firestore
  Future<void> _saveChanges(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(uid).update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
      });
      setState(() {
        _isEditing = false;
        _isOtpSent = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')));
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')));
    }
  }
}
