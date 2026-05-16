import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class CareerRoadmapPage extends StatefulWidget {
  const CareerRoadmapPage({super.key});

  @override
  State<CareerRoadmapPage> createState() => _CareerRoadmapPageState();
}

class _CareerRoadmapPageState extends State<CareerRoadmapPage>
    with SingleTickerProviderStateMixin {
  final goalController = TextEditingController();

  String selectedGoal = '';
  late AnimationController controller;

  final Map<String, List<Map<String, dynamic>>> roadmaps = {
    'flutter': [
      {
        'title': 'Step 1: Learn Dart Basics',
        'desc': 'Variables, functions, classes, lists, maps and async programming.',
        'icon': Icons.code,
      },
      {
        'title': 'Step 2: Flutter UI',
        'desc': 'Widgets, layouts, navigation, forms, themes and responsive design.',
        'icon': Icons.phone_android,
      },
      {
        'title': 'Step 3: Firebase',
        'desc': 'Authentication, Firestore, storage, hosting and real-time data.',
        'icon': Icons.cloud,
      },
      {
        'title': 'Step 4: Projects',
        'desc': 'Build apps like job portal, quiz app, chat app and resume analyzer.',
        'icon': Icons.work,
      },
      {
        'title': 'Step 5: Placement Ready',
        'desc': 'Prepare OOP, DBMS, Flutter interview questions and GitHub portfolio.',
        'icon': Icons.emoji_events,
      },
    ],
    'data analyst': [
      {
        'title': 'Step 1: Excel & Statistics',
        'desc': 'Learn formulas, charts, pivot tables, averages, percentages and basics of statistics.',
        'icon': Icons.table_chart,
      },
      {
        'title': 'Step 2: SQL',
        'desc': 'Learn SELECT, WHERE, GROUP BY, JOIN, aggregation and database queries.',
        'icon': Icons.storage,
      },
      {
        'title': 'Step 3: Python for Data',
        'desc': 'Learn Pandas, NumPy, data cleaning, filtering and basic analysis.',
        'icon': Icons.data_object,
      },
      {
        'title': 'Step 4: Visualization',
        'desc': 'Use Power BI, Tableau or charts to show insights clearly.',
        'icon': Icons.bar_chart,
      },
      {
        'title': 'Step 5: Portfolio',
        'desc': 'Build dashboards and projects using real datasets.',
        'icon': Icons.dashboard,
      },
    ],
    'software': [
      {
        'title': 'Step 1: Programming Foundation',
        'desc': 'Learn C, Java or Python with logic building and problem solving.',
        'icon': Icons.terminal,
      },
      {
        'title': 'Step 2: CS Fundamentals',
        'desc': 'OOP, DBMS, OS, networks and basic data structures.',
        'icon': Icons.memory,
      },
      {
        'title': 'Step 3: Web/App Development',
        'desc': 'Build frontend, backend or mobile app projects.',
        'icon': Icons.developer_mode,
      },
      {
        'title': 'Step 4: GitHub & Resume',
        'desc': 'Upload projects, write strong resume points and add live demos.',
        'icon': Icons.folder_copy,
      },
      {
        'title': 'Step 5: Interview Prep',
        'desc': 'Practice coding basics, HR answers and project explanation.',
        'icon': Icons.record_voice_over,
      },
    ],
    'cybersecurity': [
      {
        'title': 'Step 1: Networking Basics',
        'desc': 'Learn IP, DNS, HTTP, ports, firewalls and basic Linux commands.',
        'icon': Icons.router,
      },
      {
        'title': 'Step 2: Security Fundamentals',
        'desc': 'Understand threats, vulnerabilities, encryption and authentication.',
        'icon': Icons.security,
      },
      {
        'title': 'Step 3: Tools',
        'desc': 'Learn Wireshark, Nmap, Burp Suite and basic vulnerability scanning.',
        'icon': Icons.build,
      },
      {
        'title': 'Step 4: Safe Projects',
        'desc': 'Build password protector, phishing awareness page and security checklist.',
        'icon': Icons.lock,
      },
      {
        'title': 'Step 5: Certifications',
        'desc': 'Prepare for beginner-friendly cybersecurity certificates and internships.',
        'icon': Icons.verified,
      },
    ],
  };

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    goalController.dispose();
    controller.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> getRoadmap() {
    final goal = selectedGoal.toLowerCase();

    if (goal.contains('flutter') || goal.contains('app')) {
      return roadmaps['flutter']!;
    }

    if (goal.contains('data') || goal.contains('analyst')) {
      return roadmaps['data analyst']!;
    }

    if (goal.contains('cyber') || goal.contains('security')) {
      return roadmaps['cybersecurity']!;
    }

    return roadmaps['software']!;
  }

  String getTitle() {
    final goal = selectedGoal.trim();

    if (goal.isEmpty) {
      return 'AI Career Roadmap';
    }

    return 'Roadmap for $goal';
  }

  void generateRoadmap() {
    if (goalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your career goal first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      selectedGoal = goalController.text.trim();
    });
  }

  Color pageBg(bool isDark) {
    return isDark ? const Color(0xFF050505) : const Color(0xFFF5F5F5);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final roadmap = getRoadmap();

    return Scaffold(
      backgroundColor: pageBg(isDark),
      appBar: AppBar(
        backgroundColor: pageBg(isDark),
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
        title: Text(
          'AI Career Roadmap',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: RoadmapBackgroundPainter(
                    isDark: isDark,
                    value: controller.value,
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        heroCard(isDark),
                        const SizedBox(height: 24),
                        inputCard(isDark),
                        const SizedBox(height: 24),
                        roadmapHeader(isDark),
                        const SizedBox(height: 18),
                        ...List.generate(
                          roadmap.length,
                          (index) => roadmapStep(
                            isDark: isDark,
                            item: roadmap[index],
                            index: index,
                            isLast: index == roadmap.length - 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget heroCard(bool isDark) {
    return glassCard(
      isDark: isDark,
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: isDark ? Colors.white : Colors.black,
            child: Icon(
              Icons.route,
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
                  'AI Career Roadmap Generator',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your goal and FresherArena will generate a beginner-friendly roadmap with skills, projects and preparation steps.',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget inputCard(bool isDark) {
    return glassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What do you want to become?',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: goalController,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Example: Flutter Developer, Data Analyst, Cybersecurity Analyst',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: generateRoadmap,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Roadmap'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget roadmapHeader(bool isDark) {
    return Text(
      getTitle(),
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontSize: 30,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget roadmapStep({
    required bool isDark,
    required Map<String, dynamic> item,
    required int index,
    required bool isLast,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + index * 140),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(35 * (1 - value), 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      child: Icon(
                        item['icon'],
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 3,
                        height: 90,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                  ],
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: glassCard(
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['desc'],
                            style: const TextStyle(
                              color: Colors.grey,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget glassCard({
    required bool isDark,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
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
            borderRadius: BorderRadius.circular(28),
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

class RoadmapBackgroundPainter extends CustomPainter {
  final bool isDark;
  final double value;

  RoadmapBackgroundPainter({
    required this.isDark,
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.06);

    final random = Random(21);

    for (int i = 0; i < 55; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      final moveX = sin(value * 2 * pi + i) * 15;
      final moveY = cos(value * 2 * pi + i) * 15;

      canvas.drawCircle(
        Offset(x + moveX, y + moveY),
        random.nextDouble() * 3 + 1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RoadmapBackgroundPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}