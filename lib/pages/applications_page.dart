import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationsPage extends StatelessWidget {
  const ApplicationsPage({super.key});

  Color pageBg(bool isDark) {
    return isDark ? const Color(0xFF050505) : const Color(0xFFF5F5F5);
  }

  Future<void> updateStatus({
    required String userId,
    required String jobId,
    required String status,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('applied_jobs')
        .doc(jobId)
        .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> openResume(
    BuildContext context,
    String resumeUrl,
  ) async {
    if (resumeUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No resume uploaded by this applicant.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final uri = Uri.parse(resumeUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open resume.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> openApplyLink(
    BuildContext context,
    String applyLink,
  ) async {
    if (applyLink.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No apply link available.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final uri = Uri.parse(applyLink);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: pageBg(isDark),
      appBar: AppBar(
        backgroundColor: pageBg(isDark),
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
        title: Text(
          'Applications Dashboard',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('applied_jobs')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No applications yet.',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 20,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heroCard(isDark, docs.length),
                    const SizedBox(height: 24),
                    ...docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final userId = doc.reference.parent.parent?.id ?? '';
                      final jobId = doc.id;

                      return applicationCard(
                        context: context,
                        isDark: isDark,
                        data: data,
                        userId: userId,
                        jobId: jobId,
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget heroCard(bool isDark, int total) {
    return glassCard(
      isDark: isDark,
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: isDark ? Colors.white : Colors.black,
            child: Icon(
              Icons.assignment_turned_in,
              color: isDark ? Colors.black : Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recruiter Application Viewer',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$total student applications found across all jobs.',
                  style: const TextStyle(
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget applicationCard({
    required BuildContext context,
    required bool isDark,
    required Map<String, dynamic> data,
    required String userId,
    required String jobId,
  }) {
    final status = data['status'] ?? 'Applied';
    final resumeUrl = (data['resumeUrl'] ?? '').toString();
    final userEmail = (data['userEmail'] ?? 'Unknown applicant').toString();
    final applyLink = (data['applyLink'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: glassCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  child: Text(
                    '${data['company'] ?? 'J'}'[0].toUpperCase(),
                    style: TextStyle(
                      color: isDark ? Colors.black : Colors.white,
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
                        data['role'] ?? 'Job Role',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data['company'] ?? ''} • ${data['location'] ?? ''}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                statusChip(status),
              ],
            ),

            const SizedBox(height: 16),

            infoRow('Applicant Email', userEmail, isDark),
            infoRow('Applicant User ID', userId, isDark),
            infoRow('Salary', data['salary'] ?? '', isDark),
            infoRow('Type', data['type'] ?? '', isDark),

            const SizedBox(height: 18),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                actionButton(
                  label: 'View Resume',
                  icon: Icons.picture_as_pdf,
                  color: resumeUrl.isEmpty ? Colors.grey : Colors.blueAccent,
                  onTap: () => openResume(context, resumeUrl),
                ),
                actionButton(
                  label: 'Open Apply Link',
                  icon: Icons.open_in_new,
                  color: Colors.white70,
                  onTap: () => openApplyLink(context, applyLink),
                ),
                actionButton(
                  label: 'Shortlist',
                  icon: Icons.check_circle,
                  color: Colors.greenAccent,
                  onTap: () async {
                    await updateStatus(
                      userId: userId,
                      jobId: jobId,
                      status: 'Shortlisted',
                    );
                  },
                ),
                actionButton(
                  label: 'Reject',
                  icon: Icons.cancel,
                  color: Colors.redAccent,
                  onTap: () async {
                    await updateStatus(
                      userId: userId,
                      jobId: jobId,
                      status: 'Rejected',
                    );
                  },
                ),
                actionButton(
                  label: 'Pending',
                  icon: Icons.hourglass_empty,
                  color: Colors.orangeAccent,
                  onTap: () async {
                    await updateStatus(
                      userId: userId,
                      jobId: jobId,
                      status: 'Pending',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String title, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$title: $value',
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget statusChip(String status) {
    Color color = Colors.orangeAccent;

    if (status == 'Shortlisted') color = Colors.greenAccent;
    if (status == 'Rejected') color = Colors.redAccent;
    if (status == 'Applied') color = Colors.blueAccent;
    if (status == 'Pending') color = Colors.orangeAccent;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.45),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(
          color: color.withOpacity(0.55),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.055)
                : Colors.white.withOpacity(0.84),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.white10 : Colors.black12,
                blurRadius: 28,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}