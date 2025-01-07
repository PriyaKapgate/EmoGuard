import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Image.asset(
                    'assets/second.png',
                    height: screenWidth * 0.5,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              buildTextSection(
                  'Feeling down? Talk to a friendly AI companion 24/7 for support and encouragement.'),
              buildTextSection(
                  'Decode your moods! Analyze your diary entries to identify patterns and what makes you feel good.'),
              buildTextSection(
                  'Fun alert! Play the "Guess My Mood" game and test your emotional intelligence with a laugh.'),
              buildTextSection(
                  'Complete the mental health assessments to gain insights into your well-being.'),
              buildTextSection(
                  'Track your sleep and medications (optional) to see how they impact your overall health.'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextSection(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF49243E),
        ),
      ),
    );
  }
}
