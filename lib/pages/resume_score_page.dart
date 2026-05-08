import 'package:flutter/material.dart';

class ResumeScorePage extends StatefulWidget {
  const ResumeScorePage({super.key});

  @override
  State<ResumeScorePage> createState() => _ResumeScorePageState();
}

class _ResumeScorePageState extends State<ResumeScorePage> {
  final skillsController = TextEditingController();
  int score = 0;

  void calculateScore() {
    String skills = skillsController.text.toLowerCase();

    int match = 0;

    if (skills.contains("flutter")) match++;
    if (skills.contains("python")) match++;
    if (skills.contains("java")) match++;
    if (skills.contains("sql")) match++;

    setState(() {
      score = (match * 25);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020817),
        title: const Text("Resume Match Score"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: skillsController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter your skills (e.g. Flutter, Python)",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF0A1628),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: calculateScore,
              child: const Text("Check Score"),
            ),

            const SizedBox(height: 30),

            Text(
              "Match Score: $score%",
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}