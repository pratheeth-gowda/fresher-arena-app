import 'package:flutter/material.dart';
import 'resume_score_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020817),
        title: const Text(
          'Profile',
          style: TextStyle(color: Color(0xFF38BDF8)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFF38BDF8),
              child: Icon(Icons.person, size: 50, color: Colors.black),
            ),

            const SizedBox(height: 16),

            const Text(
              'Fresher User',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),

            const SizedBox(height: 6),

            const Text(
              'student@example.com',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            ListTile(
              tileColor: const Color(0xFF0A1628),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              leading: const Icon(Icons.analytics, color: Color(0xFF38BDF8)),
              title: const Text(
                'Resume Match Score',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Check how well your skills match jobs',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResumeScorePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}