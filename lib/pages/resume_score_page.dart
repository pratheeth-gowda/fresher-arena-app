import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ResumeScorePage extends StatefulWidget {
  const ResumeScorePage({super.key});

  @override
  State<ResumeScorePage> createState() => _ResumeScorePageState();
}

class _ResumeScorePageState extends State<ResumeScorePage> {
  bool isLoading = false;
  bool isSaving = false;

  String fileName = '';
  String extractedText = '';
  int atsScore = 0;

  final List<String> jobKeywords = [
    'flutter',
    'firebase',
    'dart',
    'ui',
    'authentication',
    'firestore',
    'api',
    'git',
    'github',
    'responsive',
    'project',
    'internship',
    'machine learning',
    'python',
    'sql',
    'communication',
    'teamwork',
  ];

  Future<void> pickResumePdf() async {
    setState(() {
      isLoading = true;
      extractedText = '';
      atsScore = 0;
      fileName = '';
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null || result.files.single.bytes == null) {
        setState(() => isLoading = false);
        return;
      }

      final Uint8List pdfBytes = result.files.single.bytes!;
      final selectedFileName = result.files.single.name;

      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      final String text = PdfTextExtractor(document).extractText();
      document.dispose();

      final int score = calculateAtsScore(text);

      setState(() {
        fileName = selectedFileName;
        extractedText = text.trim();
        atsScore = score;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        extractedText =
            'Error reading PDF. Please upload a text-based resume PDF.';
      });
    }
  }

  int calculateAtsScore(String resumeText) {
    if (resumeText.trim().isEmpty) return 0;

    final text = resumeText.toLowerCase();

    int matchedKeywords = 0;
    for (final keyword in jobKeywords) {
      if (text.contains(keyword.toLowerCase())) {
        matchedKeywords++;
      }
    }

    final int keywordScore =
        ((matchedKeywords / jobKeywords.length) * 55).round();

    int structureScore = 0;
    if (text.contains('education')) structureScore += 8;
    if (text.contains('skills')) structureScore += 8;
    if (text.contains('project') || text.contains('projects')) {
      structureScore += 8;
    }
    if (text.contains('experience') || text.contains('internship')) {
      structureScore += 8;
    }
    if (text.contains('email') || text.contains('@')) structureScore += 5;
    if (text.contains('phone') || RegExp(r'\d{10}').hasMatch(text)) {
      structureScore += 5;
    }

    int lengthScore = 0;
    final wordCount = text.split(RegExp(r'\s+')).length;
    if (wordCount >= 250 && wordCount <= 900) {
      lengthScore = 15;
    } else if (wordCount >= 150) {
      lengthScore = 8;
    }

    final total = keywordScore + structureScore + lengthScore;
    return total.clamp(0, 100);
  }

  List<String> getMatchedKeywords() {
    final text = extractedText.toLowerCase();

    return jobKeywords
        .where((keyword) => text.contains(keyword.toLowerCase()))
        .toList();
  }

  List<String> getMissingKeywords() {
    final text = extractedText.toLowerCase();

    return jobKeywords
        .where((keyword) => !text.contains(keyword.toLowerCase()))
        .toList();
  }

  List<String> getSuggestions() {
    final text = extractedText.toLowerCase();
    final List<String> suggestions = [];

    for (final keyword in getMissingKeywords()) {
      suggestions.add('Add keyword: $keyword');
    }

    if (!text.contains('skills')) {
      suggestions.add('Add a clear Skills section.');
    }
    if (!text.contains('projects') && !text.contains('project')) {
      suggestions.add('Add a Projects section with your best work.');
    }
    if (!text.contains('internship') && !text.contains('experience')) {
      suggestions.add('Add Internship or Experience details.');
    }
    if (!text.contains('@')) {
      suggestions.add('Add your email address clearly.');
    }

    return suggestions.take(6).toList();
  }

  Future<void> saveAtsResult() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Please login first.');
      return;
    }

    if (fileName.isEmpty || extractedText.isEmpty) {
      showMessage('Please upload and analyze a resume first.');
      return;
    }

    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('ats_history')
          .add({
        'fileName': fileName,
        'score': atsScore,
        'matchedKeywords': getMatchedKeywords(),
        'missingKeywords': getMissingKeywords(),
        'suggestions': getSuggestions(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => isSaving = false);
      showMessage('ATS score saved successfully.');
    } catch (e) {
      setState(() => isSaving = false);
      showMessage('Failed to save score. Check Firebase rules.');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color scoreColor() {
    if (atsScore >= 80) return Colors.greenAccent;
    if (atsScore >= 60) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String scoreLabel() {
    if (atsScore >= 80) return 'Excellent Resume Match';
    if (atsScore >= 60) return 'Good, Needs Improvement';
    return 'Needs More ATS Optimization';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final suggestions = getSuggestions();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
        title: Text(
          'AI Resume ATS Score',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 950),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                uploadCard(isDark),
                const SizedBox(height: 24),

                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                if (!isLoading && extractedText.isNotEmpty) ...[
                  scoreCard(isDark),
                  const SizedBox(height: 24),
                  suggestionsCard(isDark, suggestions),
                  const SizedBox(height: 24),
                  extractedTextCard(isDark),
                  const SizedBox(height: 30),
                ],

                if (user != null) historySection(isDark, user.uid),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget uploadCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Resume PDF',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Upload your resume PDF and FresherArena AI will extract text, check keywords, analyze structure and generate an ATS score.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              ElevatedButton.icon(
                onPressed: isLoading ? null : pickResumePdf,
                icon: const Icon(Icons.upload_file),
                label: Text(isLoading ? 'Analyzing...' : 'Choose Resume PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              if (extractedText.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: isSaving ? null : saveAtsResult,
                  icon: const Icon(Icons.cloud_done),
                  label: Text(isSaving ? 'Saving...' : 'Save ATS Result'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : Colors.black,
                    side: BorderSide(
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
            ],
          ),
          if (fileName.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Selected: $fileName',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget scoreCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: scoreColor().withOpacity(0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: scoreColor().withOpacity(0.15),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$atsScore%',
            style: TextStyle(
              fontSize: 58,
              fontWeight: FontWeight.bold,
              color: scoreColor(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scoreLabel(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: atsScore / 100,
            minHeight: 10,
            borderRadius: BorderRadius.circular(20),
            color: scoreColor(),
            backgroundColor: isDark ? Colors.white12 : Colors.black12,
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              premiumChip(
                'Matched: ${getMatchedKeywords().length}',
                Icons.check_circle,
                isDark,
              ),
              premiumChip(
                'Missing: ${getMissingKeywords().length}',
                Icons.warning_amber_rounded,
                isDark,
              ),
              premiumChip(
                'ATS Ready',
                Icons.auto_awesome,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget suggestionsCard(bool isDark, List<String> suggestions) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Suggestions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          if (suggestions.isEmpty)
            const Text(
              'Great! Your resume contains most important ATS sections and keywords.',
            )
          else
            ...suggestions.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(s)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget extractedTextCard(bool isDark) {
    return ExpansionTile(
      title: const Text(
        'View Extracted Resume Text',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.04)
                : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            extractedText,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget historySection(bool isDark, String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saved ATS History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('ats_history')
              .orderBy('createdAt', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(
                'Unable to load history. Check Firestore index/rules.',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Text(
                'No saved ATS results yet.',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              );
            }

            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final score = data['score'] ?? 0;
                final name = data['fileName'] ?? 'Resume PDF';

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor:
                            isDark ? Colors.white12 : Colors.black12,
                        child: Text(
                          '$score%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              score >= 80
                                  ? 'Excellent match'
                                  : score >= 60
                                      ? 'Good resume'
                                      : 'Needs improvement',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white60
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.history),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget premiumChip(String text, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}