import 'package:flutter/material.dart';
import 'secondpage.dart';
import 'thirdpage.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              buildFirstPageContent(),
              SecondPage(),
              ThirdPage(),
            ],
          ),
          buildPageIndicator(),
          buildNextButton(),
          buildSkipButton(),
        ],
      ),
    );
  }

  Widget buildFirstPageContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/firstpage.jpg', height: 300),
            const SizedBox(height: 20),
            const Text(
              'Mind Aid',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF49243E),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Mind Aid is your one-stop shop for managing your mental health and emotional well-being in a fun and interactive way!',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFE0A75E),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPageIndicator() {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.grey : Colors.grey[300],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget buildNextButton() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        backgroundColor: Color(0xFF49243E),
        onPressed: () {
          if (_currentPage < 2) {
            _pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            Navigator.pushReplacementNamed(context, '/container');
          }
        },
        child: Icon(
          _currentPage < 2 ? Icons.arrow_forward : Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildSkipButton() {
    return Positioned(
      bottom: 16,
      left: 16,
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/container');
        },
        child: const Text(
          'Skip',
          style: TextStyle(
            color: Color(0xFF49243E),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
