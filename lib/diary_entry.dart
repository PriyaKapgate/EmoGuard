import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:emo_guard/consts.dart';
import 'package:emo_guard/container.dart';

class DiaryEntryScreen extends StatefulWidget {
  @override
  _DiaryEntryScreenState createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
  final TextEditingController _textController = TextEditingController();
  String _formattedDate = '';
  String _report = "";

  @override
  void initState() {
    super.initState();
    _updateDate();
  }

  // Function to save diary entry and generate report
  Future<void> _saveEntry() async {
    final diaryEntry = _textController.text.trim(); // Trim whitespace
    if (diaryEntry.isEmpty) {
      _showErrorDialog(
          'Please write a diary entry before generating a report.');
      return; // Prevent empty entries
    }

    const url =
        'https://diaryanalysis-gargi-bendales-projects.vercel.app/api/generate_report';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':
              'Bearer ${GOOGLE_API_KEY}', // Make sure GOOGLE_API_KEY is defined
        },
        body: jsonEncode({'diary_entry': diaryEntry}),
      );

      if (response.statusCode == 200) {
        final report = jsonDecode(response.body)['report'];
        setState(() {
          _report = report; // Update the report variable
        });
      } else {
        // Handle error
        _showErrorDialog('Failed to generate report. Please try again.');
      }
    } catch (e) {
      print('Exception: $e');
      _showErrorDialog('An error occurred. Please try again.');
    }
  }

  // Function to update the date
  void _updateDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMMM d, yyyy');
    setState(() {
      _formattedDate = formatter.format(now);
    });
  }

  // Function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary Entry'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContainerScreen()),
            );
          },
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/diary_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 50),
              Text(
                'Today is $_formattedDate',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 58, 0, 0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                style: TextStyle(color: Color.fromARGB(255, 61, 10, 10)),
                controller: _textController,
                maxLines: 18,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Write your diary entry...',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEntry,
                child: Text('Generate Report'),
              ),
              SizedBox(height: 20),
              if (_report.isNotEmpty)
                RichText(
                  text: TextSpan(
                    children: _report.split('\n').map((line) {
                      if (line.startsWith('**')) {
                        return TextSpan(
                          text: line.replaceAll(RegExp(r'\*\*'), ''),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 82, 33, 33),
                          ),
                        );
                      } else if (line.startsWith('*')) {
                        return TextSpan(
                          text: '\u2022 ${line.replaceAll('*', '').trim()}\n',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 111, 111, 111),
                          ),
                        );
                      } else {
                        return TextSpan(
                          text: line + '\n',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        );
                      }
                    }).toList(),
                  ),
                ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_report.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: _report));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Report copied to clipboard')),
                    );
                  }
                },
                child: Text('Copy Report'),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
