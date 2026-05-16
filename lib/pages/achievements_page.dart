import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  User? get user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Color pageBg(bool isDark) {
    return isDark ? const Color(0xFF050505) : const Color(0xFFF5F5F5);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> savedJobsStream() {
    final currentUser = user;
    if (currentUser == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('saved_jobs')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> appliedJobsStream() {
    final currentUser = user;
    if (currentUser == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('applied_jobs')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> atsHistoryStream() {
    final currentUser = user;
    if (currentUser == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('ats_history')
        .snapshots();
  }

  List<Map<String, dynamic>> buildBadges({
    required int savedCount,
    required int appliedCount,
    required int atsCount,
  }) {
    return [
      {
        'title': 'Career Explorer',
        'desc': 'Opened FresherArena career dashboard.',
        'icon': Icons.explore,
        'unlocked': true,
      },
      {
        'title': 'First Job Saved',
        'desc': 'Save at least one job opportunity.',
        'icon': Icons.bookmark,
        'unlocked': savedCount >= 1,
      },
      {
        'title': 'Job Hunter',
        'desc': 'Save 3 or more job opportunities.',
        'icon': Icons.work_history,
        'unlocked': savedCount >= 3,
      },
      {
        'title': 'First Application',
        'desc': 'Apply or mark one job as applied.',
        'icon': Icons.check_circle,
        'unlocked': appliedCount >= 1,
      },
      {
        'title': 'Active Applicant',
        'desc': 'Apply for 3 or more jobs.',
        'icon': Icons.rocket_launch,
        'unlocked': appliedCount >= 3,
      },
      {
        'title': 'ATS Analyzer',
        'desc': 'Analyze and save one resume ATS score.',
        'icon': Icons.analytics,
        'unlocked': atsCount >= 1,
      },
      {
        'title': 'Resume Pro',
        'desc': 'Save 3 or more ATS analysis results.',
        'icon': Icons.description,
        'unlocked': atsCount >= 3,
      },
      {
        'title': 'Interview Ready',
        'desc': 'Practice interview questions from the coach.',
        'icon': Icons.record_voice_over,
        'unlocked': appliedCount >= 1 && atsCount >= 1,
      },
    ];
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
          'Achievements',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: savedJobsStream(),
        builder: (context, savedSnapshot) {
          final savedCount = savedSnapshot.data?.docs.length ?? 0;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: appliedJobsStream(),
            builder: (context, appliedSnapshot) {
              final appliedCount = appliedSnapshot.data?.docs.length ?? 0;

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: atsHistoryStream(),
                builder: (context, atsSnapshot) {
                  final atsCount = atsSnapshot.data?.docs.length ?? 0;

                  final badges = buildBadges(
                    savedCount: savedCount,
                    appliedCount: appliedCount,
                    atsCount: atsCount,
                  );

                  final unlocked =
                      badges.where((badge) => badge['unlocked'] == true).length;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(22),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: AnimatedBuilder(
                          animation: controller,
                          builder: (context, child) {
                            return Stack(
                              children: [
                                Positioned(
                                  right: sin(controller.value * pi) * 30,
                                  top: 60,
                                  child: glowCircle(isDark, 220),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    heroCard(
                                      isDark,
                                      unlocked,
                                      badges.length,
                                    ),
                                    const SizedBox(height: 26),
                                    badgesGrid(isDark, badges),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget heroCard(bool isDark, int unlocked, int total) {
    return glassCard(
      isDark: isDark,
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: isDark ? Colors.white : Colors.black,
            child: Icon(
              Icons.emoji_events,
              color: isDark ? Colors.black : Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Career Achievement Badges',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unlock badges by saving jobs, applying, analyzing resumes and preparing for interviews.',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  value: total == 0 ? 0 : unlocked / total,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(20),
                  color: isDark ? Colors.white : Colors.black,
                  backgroundColor: isDark ? Colors.white12 : Colors.black12,
                ),
                const SizedBox(height: 10),
                Text(
                  '$unlocked / $total badges unlocked',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget badgesGrid(bool isDark, List<Map<String, dynamic>> badges) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 750;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: badges.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: isMobile ? 3.5 : 2.8,
          ),
          itemBuilder: (context, index) {
            final badge = badges[index];
            final unlocked = badge['unlocked'] == true;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 450 + index * 90),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: glassCard(
                    isDark: isDark,
                    borderColor: unlocked
                        ? Colors.greenAccent.withOpacity(0.45)
                        : null,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: unlocked
                              ? Colors.greenAccent.withOpacity(0.18)
                              : isDark
                                  ? Colors.white10
                                  : Colors.black12,
                          child: Icon(
                            badge['icon'],
                            color: unlocked
                                ? Colors.greenAccent
                                : Colors.grey,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                badge['title'],
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white : Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                badge['desc'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          unlocked ? Icons.lock_open : Icons.lock,
                          color: unlocked ? Colors.greenAccent : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget glassCard({
    required bool isDark,
    required Widget child,
    Color? borderColor,
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
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.055)
                : Colors.white.withOpacity(0.84),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: borderColor ??
                  (isDark ? Colors.white12 : Colors.black12),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.white10 : Colors.black12,
                blurRadius: 28,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget glowCircle(bool isDark, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.white10 : Colors.black12,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.white24 : Colors.black12,
            blurRadius: 110,
            spreadRadius: 28,
          ),
        ],
      ),
    );
  }
}