import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../models/job.dart';

class JobMatchPage extends StatefulWidget {
  const JobMatchPage({super.key});

  @override
  State<JobMatchPage> createState() => _JobMatchPageState();
}

class _JobMatchPageState extends State<JobMatchPage> {
  bool isLoading = false;
  String fileName = '';
  String resumeText = '';

  final List<String> commonSkills = [
    'java',
    'python',
    'c',
    'c++',
    'dart',
    'flutter',
    'firebase',
    'sql',
    'html',
    'css',
    'javascript',
    'react',
    'software',
    'programming',
    'development',
    'database',
    'git',
    'github',
    'communication',
    'teamwork',
    'problem solving',
    'customer support',
    'operations',
    'business',
    'analytics',
    'excel',
  ];

  Future<void> uploadResume() async {
    setState(() {
      isLoading = true;
      fileName = '';
      resumeText = '';
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

      setState(() {
        fileName = selectedFileName;
        resumeText = text.toLowerCase();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        resumeText = '';
        isLoading = false;
      });

      showMessage('Unable to read PDF. Please upload a text-based resume.');
    }
  }

  List<String> keywordsForJob(Job job) {
    final combinedText =
        '${job.role} ${job.company} ${job.location} ${job.type} ${job.description}'
            .toLowerCase();

    final List<String> keywords = [];

    for (final skill in commonSkills) {
      if (combinedText.contains(skill.toLowerCase())) {
        keywords.add(skill);
      }
    }

    if (job.role.toLowerCase().contains('software')) {
      keywords.addAll([
        'software',
        'programming',
        'development',
        'java',
        'python',
        'sql',
      ]);
    }

    if (job.role.toLowerCase().contains('trainee')) {
      keywords.addAll([
        'learning',
        'training',
        'communication',
        'teamwork',
        'problem solving',
      ]);
    }

    if (job.role.toLowerCase().contains('bps')) {
      keywords.addAll([
        'business',
        'customer support',
        'operations',
        'communication',
        'excel',
      ]);
    }

    if (job.description.toLowerCase().contains('business')) {
      keywords.addAll([
        'business',
        'operations',
        'communication',
      ]);
    }

    if (job.description.toLowerCase().contains('technology')) {
      keywords.addAll([
        'technology',
        'software',
        'programming',
      ]);
    }

    return keywords.toSet().toList();
  }

  int calculateMatch(Job job) {
    if (resumeText.trim().isEmpty) return 0;

    final keywords = keywordsForJob(job);

    if (keywords.isEmpty) return 45;

    int matched = 0;

    for (final keyword in keywords) {
      if (resumeText.contains(keyword.toLowerCase())) {
        matched++;
      }
    }

    final score = ((matched / keywords.length) * 100).round();

    if (score == 0) return 25;
    return score.clamp(0, 100);
  }

  List<String> matchedSkills(Job job) {
    final keywords = keywordsForJob(job);

    return keywords
        .where((skill) => resumeText.contains(skill.toLowerCase()))
        .toSet()
        .toList();
  }

  List<String> missingSkills(Job job) {
    final keywords = keywordsForJob(job);

    return keywords
        .where((skill) => !resumeText.contains(skill.toLowerCase()))
        .toSet()
        .toList();
  }

  List<Job> sortJobsByMatch(List<Job> jobs) {
    final sortedJobs = List<Job>.from(jobs);

    sortedJobs.sort((a, b) {
      return calculateMatch(b).compareTo(calculateMatch(a));
    });

    return sortedJobs;
  }

  Color matchColor(int score) {
    if (score >= 75) return Colors.greenAccent;
    if (score >= 50) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String matchLabel(int score) {
    if (score >= 75) return 'Strong Match';
    if (score >= 50) return 'Good Match';
    return 'Needs Improvement';
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

  Stream<QuerySnapshot> jobsStream() {
    return FirebaseFirestore.instance.collection('Jobs').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
        title: Text(
          'AI Job Match',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: jobsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load jobs from Firebase.',
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final jobs = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Job.fromFirestore(doc.id, data);
          }).toList();

          final recommendedJobs = resumeText.isEmpty
              ? jobs
              : sortJobsByMatch(jobs);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heroCard(isDark, jobs.length),
                    const SizedBox(height: 26),

                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    if (!isLoading && resumeText.isEmpty)
                      emptyState(isDark),

                    if (!isLoading && resumeText.isNotEmpty) ...[
                      const Text(
                        'Recommended Jobs From Firebase',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ...recommendedJobs.map(
                        (job) => jobMatchCard(job, isDark),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget heroCard(bool isDark, int totalJobs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withOpacity(0.04)
                : Colors.black.withOpacity(0.05),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.psychology_alt_rounded,
            size: 46,
            color: isDark ? Colors.white : Colors.black,
          ),
          const SizedBox(height: 18),
          const Text(
            'AI Job Match System',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Upload your resume and FresherArena AI will compare it with the live jobs stored in Firebase.',
            style: TextStyle(
              fontSize: 16,
              height: 1.7,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Live Firebase Jobs: $totalJobs',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: isLoading ? null : uploadResume,
            icon: const Icon(Icons.upload_file),
            label: Text(
              isLoading ? 'Analyzing Resume...' : 'Upload Resume PDF',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 26,
                vertical: 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          if (fileName.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Selected: $fileName',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget emptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
      ),
      child: Text(
        'Upload your resume PDF to see job match percentages for your Firebase jobs.',
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          height: 1.6,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget jobMatchCard(Job job, bool isDark) {
    final score = calculateMatch(job);
    final matched = matchedSkills(job);
    final missing = missingSkills(job);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: matchColor(score).withOpacity(0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: matchColor(score).withOpacity(0.12),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                child: Text(
                  '$score%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: matchColor(score),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.role,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${job.company} • ${job.location} • ${job.salary}',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                matchLabel(score),
                style: TextStyle(
                  color: matchColor(score),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: score / 100,
            minHeight: 9,
            borderRadius: BorderRadius.circular(20),
            color: matchColor(score),
            backgroundColor: isDark ? Colors.white12 : Colors.black12,
          ),
          const SizedBox(height: 18),
          Text(
            job.description,
            style: TextStyle(
              height: 1.6,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              infoChip(job.type, Icons.work_outline, isDark),
              infoChip(job.location, Icons.location_on_outlined, isDark),
              infoChip(job.company, Icons.business, isDark),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Matched Skills',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (matched.isEmpty)
            Text(
              'No major skills matched yet.',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: matched
                  .map(
                    (skill) => skillChip(
                      skill,
                      Icons.check_circle,
                      Colors.greenAccent,
                      isDark,
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 18),
          const Text(
            'Missing Skills To Improve',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: missing
                .take(8)
                .map(
                  (skill) => skillChip(
                    skill,
                    Icons.add_circle_outline,
                    Colors.orangeAccent,
                    isDark,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget infoChip(String text, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget skillChip(
    String text,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}