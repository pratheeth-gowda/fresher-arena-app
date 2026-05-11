import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/job.dart';
import '../widgets/ai_section.dart';
import 'job_details_page.dart';
import 'profile_page.dart';

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
  List<Job> savedJobs = [];

  late AnimationController _controller;
  late Animation<double> floatingAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    floatingAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleSave(Job job) {
    setState(() {
      if (savedJobs.any((savedJob) => savedJob.id == job.id)) {
        savedJobs.removeWhere((savedJob) => savedJob.id == job.id);
      } else {
        savedJobs.add(job);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
        elevation: 0,
        title: Text(
          'FRESHER ARENA',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            onPressed: widget.toggleTheme,
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: currentIndex == 0
          ? buildHome(isDark)
          : currentIndex == 1
              ? buildSavedPage(isDark)
              : const ProfilePage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
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
            icon: Icon(Icons.favorite_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget buildHome(bool isDark) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Jobs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading jobs',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final jobs = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Job.fromFirestore(doc.id, data);
          }).where((job) {
            return job.role.toLowerCase().contains(search.toLowerCase()) ||
                job.company.toLowerCase().contains(search.toLowerCase()) ||
                job.location.toLowerCase().contains(search.toLowerCase());
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHero(isDark),
                const SizedBox(height: 30),
                buildStats(isDark),
                const SizedBox(height: 30),
                buildCompanies(isDark),
                const SizedBox(height: 30),
                AiSection(isDark: isDark),
                const SizedBox(height: 30),
                buildSearchBar(isDark),
                const SizedBox(height: 32),
                Text(
                  'Live Opportunities',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                buildJobsGrid(jobs, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildHero(bool isDark) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: ParticlePainter(isDark),
            ),
          ),
        ),
        TweenAnimationBuilder(
          tween: Tween(begin: 0.95, end: 1.0),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(42),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.white10 : Colors.black12,
                          blurRadius: 50,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black12,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'PREMIUM STARTUP EXPERIENCE',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: isDark
                                  ? [Colors.white, Colors.grey.shade500]
                                  : [Colors.black, Colors.grey.shade700],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'FRESHER\nARENA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 74,
                              fontWeight: FontWeight.w900,
                              height: 0.9,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TweenAnimationBuilder(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1200),
                          builder: (context, opacity, child) {
                            return Opacity(
                              opacity: opacity,
                              child: SizedBox(
                                width: 620,
                                child: Text(
                                  'Discover fresher jobs, internships and startup opportunities with an immersive modern platform experience.',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 18,
                                    height: 1.8,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [Colors.white, Colors.grey.shade300]
                                      : [Colors.black, Colors.grey.shade800],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        isDark ? Colors.white24 : Colors.black26,
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor:
                                      isDark ? Colors.black : Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 22,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text('Explore Jobs'),
                              ),
                            ),
                            const SizedBox(width: 18),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color:
                                      isDark ? Colors.white24 : Colors.black26,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 22,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                'Resume Score',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: floatingAnimation,
          builder: (context, child) {
            return Positioned(
              right: -40,
              top: floatingAnimation.value,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white10 : Colors.black12,
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.white24 : Colors.black12,
                      blurRadius: 120,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildStats(bool isDark) {
    final stats = [
      ['500+', 'Jobs'],
      ['120+', 'Companies'],
      ['10K+', 'Users'],
    ];

    return Row(
      children: stats.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;

        return Expanded(
          child: TweenAnimationBuilder(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: Duration(milliseconds: 500 + index * 200),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.white10 : Colors.black12,
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            stat[0],
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            stat[1],
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget buildCompanies(bool isDark) {
    final companies = [
      'Google',
      'Infosys',
      'TCS',
      'Wipro',
      'Accenture',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Companies',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: companies.map((company) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.white10 : Colors.black12,
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Text(
                company,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildSearchBar(bool isDark) {
    return TextField(
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        hintText: 'Search jobs, companies or city...',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.white.withOpacity(0.75),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        setState(() {
          search = value;
        });
      },
    );
  }

  Widget buildJobsGrid(List<Job> jobs, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: jobs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final job = jobs[index];

        final isSaved = savedJobs.any(
          (savedJob) => savedJob.id == job.id,
        );

        return TweenAnimationBuilder(
          tween: Tween(begin: 0.95, end: 1.0),
          duration: Duration(milliseconds: 300 + index * 100),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailsPage(job: job),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.04)
                        : Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.white10 : Colors.black12,
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor:
                                isDark ? Colors.white : Colors.black,
                            child: Text(
                              job.company.isNotEmpty ? job.company[0] : 'J',
                              style: TextStyle(
                                color: isDark ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => toggleSave(job),
                            icon: Icon(
                              isSaved
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isSaved ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        job.role,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        job.company,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${job.location} • ${job.type}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Spacer(),
                      Text(
                        job.salary,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
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
  }

  Widget buildSavedPage(bool isDark) {
    return Center(
      child: Text(
        'Saved Jobs',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 24,
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final bool isDark;

  ParticlePainter(this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white10 : Colors.black12;

    final random = Random(4);

    for (int i = 0; i < 40; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}