import 'package:flutter/material.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF020817),
      body: Center(
        child: Text(
          "Saved Jobs (Coming Soon)",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}