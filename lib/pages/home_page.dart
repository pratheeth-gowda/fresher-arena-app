import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/job.dart';
import '../widgets/ai_section.dart';
import 'achievements_page.dart';
import 'admin_page.dart';
import 'analytics_page.dart';
import 'career_roadmap_page.dart';
import 'interview_page.dart';
import 'job_details_page.dart';
import 'profile_page.dart';
import 'quiz_page.dart';
import 'notifications_page.dart';
import 'ai_chat_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomePage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  String search = '';

  late AnimationController controller;

  User? get user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
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

    if (currentUser == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('saved_jobs')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> appliedJobsStream() {
    final currentUser = user;

    if (currentUser == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('applied_jobs')
        .snapshots();
  }

  Future<void> toggleSave(Job job, bool currentlySaved) async {
    final currentUser = user;

    if (currentUser == null) {
      showToast('Please login first.');
      return;
    }

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('saved_jobs')
        .doc(job.id);

    if (currentlySaved) {
      await ref.delete();
      showToast('Removed from saved jobs.');
    } else {
      await ref.set({
        'jobId': job.id,
        'role': job.role,
        'company': job.company,
        'location': job.location,
        'salary': job.salary,
        'type': job.type,
        'description': job.description,
        'applyLink': job.applyLink,
        'savedAt': FieldValue.serverTimestamp(),
      });

      showToast('Job saved successfully.');
    }
  }

  Future<void> markApplied(Job job) async {
    final currentUser = user;

    if (currentUser == null) {
      showToast('Please login first.');
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final userData = userDoc.data();
    final resumeUrl = userData?['resumeUrl'] ?? '';

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('applied_jobs')
        .doc(job.id)
        .set({
      'jobId': job.id,
      'role': job.role,
      'company': job.company,
      'location': job.location,
      'salary': job.salary,
      'type': job.type,
      'description': job.description,
      'applyLink': job.applyLink,
      'resumeUrl': resumeUrl,
      'userEmail': currentUser.email,
      'status': 'Applied',
      'appliedAt': FieldValue.serverTimestamp(),
    });

    showToast('Marked as applied.');
  }

  void showToast(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Job> filterJobs(List<Job> jobs) {
    final query = search.toLowerCase().trim();

    if (query.isEmpty) return jobs;

    return jobs.where((job) {
      return job.role.toLowerCase().contains(query) ||
          job.company.toLowerCase().contains(query) ||
          job.location.toLowerCase().contains(query) ||
          job.type.toLowerCase().contains(query) ||
          job.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: pageBg(isDark),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: pageBg(isDark).withOpacity(0.9),
        elevation: 0,
        title: Text(
          'FRESHER ARENA',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        actions: [

          StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('notifications')
        .snapshots(),
    builder: (context, snapshot) {
      final count = snapshot.data?.docs.length ?? 0;

      return Stack(
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const NotificationsPage(),
                ),
              );
            },
            icon: Icon(
              Icons.notifications_none,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          if (count > 0)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  ),


          IconButton(
            onPressed: widget.toggleTheme,
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: currentIndex == 0
          ? buildHome(isDark)
          : currentIndex == 1
              ? buildSavedJobs(isDark)
              : ProfilePage(
    toggleTheme: widget.toggleTheme,
    isDarkMode: widget.isDarkMode,
  ),

      floatingActionButton: FloatingActionButton.extended(
  backgroundColor: Colors.greenAccent,
  foregroundColor: Colors.black,
  elevation: 10,
  icon: const Icon(Icons.smart_toy),
  label: const Text(
    'AI Assistant',
    style: TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AiChatPage(),
      ),
    );
  },
),

      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(26),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20,
            sigmaY: 20,
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            backgroundColor: isDark
                ? Colors.black.withOpacity(0.8)
                : Colors.white.withOpacity(0.85),
            selectedItemColor: isDark ? Colors.white : Colors.black,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.work_outline),
                label: 'Jobs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_border),
                label: 'Saved',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHome(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Jobs').snapshots(),
      builder: (context, jobsSnapshot) {
        if (jobsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (jobsSnapshot.hasError) {
          return const Center(
            child: Text(
              'Error loading jobs',
              style: TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final allJobs = jobsSnapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Job.fromFirestore(doc.id, data);
        }).toList();

        final jobs = filterJobs(allJobs);

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: savedJobsStream(),
          builder: (context, savedSnapshot) {
            final savedIds =
                savedSnapshot.data?.docs.map((doc) => doc.id).toSet() ??
                    <String>{};

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: appliedJobsStream(),
              builder: (context, appliedSnapshot) {
                final appliedIds =
                    appliedSnapshot.data?.docs.map((doc) => doc.id).toSet() ??
                        <String>{};

                return AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: AnimatedBackgroundPainter(
                              isDark: isDark,
                              value: controller.value,
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            24,
                            24,
                            24,
                            130,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              heroSection(isDark),
                              const SizedBox(height: 30),
                              statsSection(
                                isDark,
                                allJobs.length,
                                savedIds.length,
                                appliedIds.length,
                              ),
                              const SizedBox(height: 30),
                              actionButtons(isDark),
                              const SizedBox(height: 30),
                              companiesSection(isDark, allJobs),
                              const SizedBox(height: 30),
                              AiSection(isDark: isDark),
                              const SizedBox(height: 30),
                              searchBar(isDark),
                              const SizedBox(height: 36),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Live Opportunities',
                                      style: TextStyle(
                                        color:
                                            isDark ? Colors.white : Colors.black,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${jobs.length} found',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              jobsGrid(
                                jobs,
                                isDark,
                                savedIds,
                                appliedIds,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget heroSection(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 850;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 40 * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: glassContainer(
                  isDark: isDark,
                  padding: const EdgeInsets.all(42),
                  radius: 38,
                  child: Flex(
                    direction: isMobile ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: isMobile ? 0 : 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            premiumBadge(
                              'AI POWERED CAREER PLATFORM',
                              isDark,
                            ),
                            const SizedBox(height: 30),
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: isDark
                                      ? [
                                          Colors.white,
                                          Colors.grey.shade500,
                                        ]
                                      : [
                                          Colors.black,
                                          Colors.grey.shade700,
                                        ],
                                ).createShader(bounds);
                              },
                              child: const Text(
                                'FRESHER\nARENA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 74,
                                  fontWeight: FontWeight.w900,
                                  height: 0.92,
                                  letterSpacing: -2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'A futuristic fresher hiring platform with Firebase jobs, ATS score analysis, analytics, interview coach and achievements.',
                              style: TextStyle(
                                color:
                                    isDark ? Colors.white60 : Colors.black54,
                                fontSize: 18,
                                height: 1.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: isMobile ? 0 : 30,
                        height: isMobile ? 35 : 0,
                      ),
                      Expanded(
                        flex: isMobile ? 0 : 1,
                        child: animatedHeroOrb(isDark),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget animatedHeroOrb(bool isDark) {
    return SizedBox(
      height: 280,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final rotation = controller.value * 2 * pi;

          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: rotation,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.black26,
                      width: 2,
                    ),
                  ),
                ),
              ),
              Transform.rotate(
                angle: -rotation * 1.4,
                child: Container(
                  width: 185,
                  height: 185,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white38 : Colors.black38,
                      width: 2,
                    ),
                  ),
                ),
              ),
              Transform.scale(
                scale: 1 + sin(controller.value * 2 * pi) * 0.08,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              Colors.white,
                              Colors.grey.shade400,
                            ]
                          : [
                              Colors.black,
                              Colors.grey.shade700,
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.white24 : Colors.black26,
                        blurRadius: 60,
                        spreadRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: isDark ? Colors.black : Colors.white,
                    size: 55,
                  ),
                ),
              ),
              orbitIcon(Icons.work, rotation, 105, isDark),
              orbitIcon(Icons.analytics, rotation + 2, 105, isDark),
              orbitIcon(Icons.psychology, rotation + 4, 105, isDark),
              orbitIcon(Icons.rocket_launch, rotation + 1, 140, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget orbitIcon(
    IconData icon,
    double angle,
    double radius,
    bool isDark,
  ) {
    return Transform.translate(
      offset: Offset(
        cos(angle) * radius,
        sin(angle) * radius,
      ),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: isDark ? Colors.white : Colors.black,
        child: Icon(
          icon,
          color: isDark ? Colors.black : Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget statsSection(
    bool isDark,
    int totalJobs,
    int savedJobs,
    int appliedJobs,
  ) {
    final stats = [
      [totalJobs.toString(), 'Total Jobs', Icons.work_outline],
      [savedJobs.toString(), 'Saved Jobs', Icons.bookmark_border],
      [appliedJobs.toString(), 'Applied Jobs', Icons.check_circle_outline],
      ['AI', 'Smart Match', Icons.psychology_alt_outlined],
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 850;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile ? 4.2 : 1.75,
          ),
          itemBuilder: (context, index) {
            final stat = stats[index];

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 500 + index * 130),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 35 * (1 - value)),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: glassContainer(
                      isDark: isDark,
                      padding: const EdgeInsets.all(20),
                      radius: 28,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor:
                                isDark ? Colors.white12 : Colors.black12,
                            child: Icon(
                              stat[2] as IconData,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  stat[0] as String,
                                  style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  stat[1] as String,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget actionButtons(bool isDark) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        premiumActionButton(
          isDark: isDark,
          icon: Icons.analytics,
          title: 'Analytics',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AnalyticsPage(),
              ),
            );
          },
        ),
        premiumActionButton(
          isDark: isDark,
          icon: Icons.sports_esports,
          title: 'Quiz Game',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QuizPage(),
              ),
            );
          },
        ),
        premiumActionButton(
          isDark: isDark,
          icon: Icons.record_voice_over,
          title: 'Interview Coach',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InterviewPage(),
              ),
            );
          },
        ),
        premiumActionButton(
          isDark: isDark,
          icon: Icons.emoji_events,
          title: 'Achievements',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AchievementsPage(),
              ),
            );
          },
        ),
        premiumActionButton(
          isDark: isDark,
          icon: Icons.route,
          title: 'Career Roadmap',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CareerRoadmapPage(),
              ),
            );
          },
        ),
        premiumActionButton(
          isDark: isDark,
          icon: Icons.admin_panel_settings,
          title: 'Admin Panel',
          onTap: () {
            final currentUser = FirebaseAuth.instance.currentUser;

            if (currentUser?.email == 'pratheethnvn@gmail.com') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminPage(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Access denied. Admin only.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget premiumActionButton({
    required bool isDark,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            sin(controller.value * 2 * pi) * 2,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        Colors.white,
                        Colors.grey.shade300,
                      ]
                    : [
                        Colors.black,
                        Colors.grey.shade800,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.white24 : Colors.black26,
                  blurRadius: 24,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon),
              label: Text(title),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget companiesSection(bool isDark, List<Job> jobs) {
    final companies = jobs.map((job) => job.company).toSet().toList();

    if (companies.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Hiring Companies',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: companies.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final company = companies[index];

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 500 + index * 100),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 22 * (1 - value)),
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: glassContainer(
                        isDark: isDark,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        radius: 22,
                        child: Center(
                          child: Text(
                            company,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget searchBar(bool isDark) {
    return glassContainer(
      isDark: isDark,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      radius: 24,
      child: TextField(
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Search jobs, company, city, type...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          suffixIcon: search.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      search = '';
                    });
                  },
                  icon: const Icon(Icons.close),
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            search = value;
          });
        },
      ),
    );
  }

  Widget jobsGrid(
    List<Job> jobs,
    bool isDark,
    Set<String> savedIds,
    Set<String> appliedIds,
  ) {
    if (jobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'No jobs found.',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 850;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: jobs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: isMobile ? 0.78 : 0.95,
          ),
          itemBuilder: (context, index) {
            final job = jobs[index];
            final isSaved = savedIds.contains(job.id);
            final isApplied = appliedIds.contains(job.id);

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 450 + index * 100),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 35 * (1 - value)),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: jobCard(
                      job,
                      isDark,
                      isSaved,
                      isApplied,
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

  Widget jobCard(
    Job job,
    bool isDark,
    bool isSaved,
    bool isApplied,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsPage(job: job),
          ),
        );
      },
      child: glassContainer(
        isDark: isDark,
        padding: const EdgeInsets.all(24),
        radius: 30,
        borderColor: isApplied ? Colors.greenAccent.withOpacity(0.55) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 86,
                  height: 86,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Image.network(
                    companyLogoUrl(job.company),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          job.company.isNotEmpty
                              ? job.company[0].toUpperCase()
                              : 'J',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.role,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              job.company,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            color: Colors.greenAccent,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              job.location,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.work_outline,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              job.type,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => toggleSave(job, isSaved),
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? Colors.amber : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                tagChip(isDark, categoryForCompany(job.company)),
                const SizedBox(width: 10),
                tagChip(isDark, 'Fresher'),
              ],
            ),
            const SizedBox(height: 18),
            Divider(color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 16),
            sectionHeader(
              isDark,
              Icons.business,
              'About the Company',
            ),
            const SizedBox(height: 12),
            Text(
              aboutCompany(job.company),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.grey,
                height: 1.55,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: companyStats(job.company).map((item) {
                return statMiniBox(
                  isDark,
                  item['icon'] as IconData,
                  item['value'] as String,
                  item['label'] as String,
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Divider(color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 14),
            sectionHeader(
              isDark,
              Icons.star_border,
              'Role Highlights',
            ),
            const SizedBox(height: 10),
            ...roleHighlights(job).map((point) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '•',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        point,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.salary,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => markApplied(job),
                  child: Text(isApplied ? 'Applied' : 'Mark Applied'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String companyLogoUrl(String company) {
    final c = company.toLowerCase();

    if (c.contains('tcs')) {
      return 'https://logo.clearbit.com/tcs.com';
    }

    if (c.contains('infosys')) {
      return 'https://logo.clearbit.com/infosys.com';
    }

    if (c.contains('accenture')) {
      return 'https://logo.clearbit.com/accenture.com';
    }

    if (c.contains('wipro')) {
      return 'https://logo.clearbit.com/wipro.com';
    }

    return 'https://ui-avatars.com/api/?name=$company&background=ffffff&color=000000&bold=true';
  }

  String aboutCompany(String company) {
    final c = company.toLowerCase();

    if (c.contains('tcs')) {
      return 'Tata Consultancy Services is a global IT services and consulting company helping businesses with technology, digital solutions, and innovation.';
    }

    if (c.contains('infosys')) {
      return 'Infosys is a leading global technology company providing consulting, software development, and digital transformation services.';
    }

    if (c.contains('accenture')) {
      return 'Accenture is a global professional services company specializing in technology, consulting, cloud, and digital solutions.';
    }

    if (c.contains('wipro')) {
      return 'Wipro is a global IT, consulting, and business process services company focused on innovation and client solutions.';
    }

    return '$company offers career opportunities for freshers to learn, grow, and work on real-world business and technology projects.';
  }

  String categoryForCompany(String company) {
    final c = company.toLowerCase();

    if (c.contains('tcs')) return 'IT Services';
    if (c.contains('infosys')) return 'Technology';
    if (c.contains('accenture')) return 'Consulting';
    if (c.contains('wipro')) return 'IT Solutions';

    return 'Hiring';
  }

  List<Map<String, Object>> companyStats(String company) {
    final c = company.toLowerCase();

    if (c.contains('tcs')) {
      return [
        {'icon': Icons.groups, 'value': '600K+', 'label': 'Employees'},
        {'icon': Icons.public, 'value': '55+', 'label': 'Countries'},
        {'icon': Icons.trending_up, 'value': 'Global', 'label': 'Leader'},
      ];
    }

    if (c.contains('infosys')) {
      return [
        {'icon': Icons.groups, 'value': '300K+', 'label': 'Employees'},
        {'icon': Icons.public, 'value': '50+', 'label': 'Countries'},
        {'icon': Icons.calendar_month, 'value': '1981', 'label': 'Founded'},
      ];
    }

    if (c.contains('accenture')) {
      return [
        {'icon': Icons.groups, 'value': '700K+', 'label': 'Employees'},
        {'icon': Icons.public, 'value': '120+', 'label': 'Countries'},
        {'icon': Icons.trending_up, 'value': 'Global', 'label': 'Consulting'},
      ];
    }

    if (c.contains('wipro')) {
      return [
        {'icon': Icons.groups, 'value': '240K+', 'label': 'Employees'},
        {'icon': Icons.public, 'value': '60+', 'label': 'Countries'},
        {'icon': Icons.calendar_month, 'value': '1945', 'label': 'Founded'},
      ];
    }

    return [
      {'icon': Icons.groups, 'value': 'Growing', 'label': 'Team'},
      {'icon': Icons.public, 'value': 'India', 'label': 'Location'},
      {'icon': Icons.trending_up, 'value': 'Active', 'label': 'Hiring'},
    ];
  }

  List<String> roleHighlights(Job job) {
    final text = '${job.role} ${job.description}'.toLowerCase();

    if (text.contains('software') || text.contains('developer')) {
      return [
        'Work on real-world software development tasks.',
        'Improve coding, debugging, and project-building skills.',
        'Good opportunity for freshers interested in technology.',
      ];
    }

    if (text.contains('bps') || text.contains('operations')) {
      return [
        'Entry-level role with structured training.',
        'Build communication and business process skills.',
        'Suitable for freshers starting a corporate career.',
      ];
    }

    if (text.contains('data')) {
      return [
        'Work with business data and reports.',
        'Improve analytical and problem-solving skills.',
        'Good fit for freshers interested in data careers.',
      ];
    }

    return [
      'Fresher-friendly opportunity with learning scope.',
      'Gain practical exposure in a professional environment.',
      'Build career experience with a reputed company.',
    ];
  }

  Widget sectionHeader(
    bool isDark,
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.greenAccent,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget tagChip(
    bool isDark,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget statMiniBox(
    bool isDark,
    IconData icon,
    String value,
    String label,
  ) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.greenAccent,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSavedJobs(bool isDark) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: savedJobsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Text(
              'No saved jobs yet.',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 20,
              ),
            ),
          );
        }

        final savedJobs = docs.map((doc) {
          final data = doc.data();

          return Job(
            id: data['jobId'] ?? doc.id,
            role: data['role'] ?? '',
            company: data['company'] ?? '',
            location: data['location'] ?? '',
            salary: data['salary'] ?? '',
            type: data['type'] ?? '',
            description: data['description'] ?? '',
            applyLink: data['applyLink'] ?? '',
          );
        }).toList();

        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: AnimatedBackgroundPainter(
                      isDark: isDark,
                      value: controller.value,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    130,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saved Jobs',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      jobsGrid(
                        savedJobs,
                        isDark,
                        savedJobs.map((job) => job.id).toSet(),
                        {},
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget premiumBadge(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black12,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget glassContainer({
    required bool isDark,
    required Widget child,
    required EdgeInsets padding,
    double radius = 30,
    Color? borderColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.055)
                : Colors.white.withOpacity(0.84),
            borderRadius: BorderRadius.circular(radius),
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
}

class AnimatedBackgroundPainter extends CustomPainter {
  final bool isDark;
  final double value;

  AnimatedBackgroundPainter({
    required this.isDark,
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          sin(value * 2 * pi) * 0.5,
          cos(value * 2 * pi) * 0.5,
        ),
        radius: 1.2,
        colors: isDark
            ? [
                Colors.white.withOpacity(0.13),
                Colors.transparent,
              ]
            : [
                Colors.black.withOpacity(0.08),
                Colors.transparent,
              ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
      bgPaint,
    );

    final particlePaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.09)
          : Colors.black.withOpacity(0.08);

    final random = Random(12);

    for (int i = 0; i < 70; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      final moveX = sin(value * 2 * pi + i) * 18;
      final moveY = cos(value * 2 * pi + i) * 18;

      canvas.drawCircle(
        Offset(
          baseX + moveX,
          baseY + moveY,
        ),
        random.nextDouble() * 3 + 1,
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedBackgroundPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}