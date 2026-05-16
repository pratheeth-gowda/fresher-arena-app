import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ResumeUploadPage extends StatefulWidget {
  const ResumeUploadPage({super.key});

  @override
  State<ResumeUploadPage> createState() => _ResumeUploadPageState();
}

class _ResumeUploadPageState extends State<ResumeUploadPage> {
  bool isUploading = false;
  String uploadedResumeUrl = '';

  Future<void> uploadResume() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Please login first.');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    final Uint8List bytes = result.files.single.bytes!;
    final fileName = result.files.single.name;

    setState(() => isUploading = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('resumes')
          .child(user.uid)
          .child(fileName);

      await ref.putData(bytes);

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'resumeUrl': url,
        'resumeFileName': fileName,
        'resumeUploadedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        uploadedResumeUrl = url;
        isUploading = false;
      });

      showMessage('Resume uploaded and saved successfully.');
    } catch (e) {
      setState(() => isUploading = false);
      showMessage('Upload failed: $e');
    }
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  Color pageBg(bool isDark) {
    return isDark ? const Color(0xFF050505) : const Color(0xFFF5F5F5);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: pageBg(isDark),
      appBar: AppBar(
        backgroundColor: pageBg(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text(
          'Resume Upload',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: glassCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload Your Resume',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your resume will be stored securely and attached to your job applications.',
                    style: TextStyle(color: Colors.grey, height: 1.6),
                  ),
                  const SizedBox(height: 28),
                  uploadBox(isDark),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: isUploading ? null : uploadResume,
                      icon: isUploading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(
                        isUploading ? 'Uploading Resume...' : 'Upload Resume PDF',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  if (uploadedResumeUrl.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.greenAccent.withOpacity(0.45),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.greenAccent),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Resume uploaded successfully. Recruiters can view it from your applications.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget uploadBox(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 76,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          const SizedBox(height: 18),
          const Text(
            'PDF Resume Only',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget glassCard({
    required bool isDark,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.055) : Colors.white.withOpacity(0.84),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          ),
          child: child,
        ),
      ),
    );
  }
}