import 'package:flutter/material.dart';

class ResumeScorePage extends StatefulWidget {
  const ResumeScorePage({super.key});

  @override
  State<ResumeScorePage> createState() => _ResumeScorePageState();
}

class _ResumeScorePageState extends State<ResumeScorePage>
    with SingleTickerProviderStateMixin {
  final skillsController = TextEditingController();
  int score = 0;
  List<String> missingSkills = [];
  bool checked = false;

  late AnimationController _controller;
  late Animation<double> floatingAnimation;

  final requiredSkills = [
    'flutter',
    'firebase',
    'python',
    'sql',
    'java',
    'communication',
  ];

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
    skillsController.dispose();
    super.dispose();
  }

  void calculateScore() {
    final input = skillsController.text.toLowerCase();

    int matched = 0;
    List<String> missing = [];

    for (final skill in requiredSkills) {
      if (input.contains(skill)) {
        matched++;
      } else {
        missing.add(skill);
      }
    }

    setState(() {
      score = ((matched / requiredSkills.length) * 100).round();
      missingSkills = missing;
      checked = true;
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
          'Resume Match Score',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: floatingAnimation,
                  builder: (context, child) {
                    return Positioned(
                      right: floatingAnimation.value,
                      top: 40,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.white10 : Colors.black12,
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.white24 : Colors.black12,
                              blurRadius: 100,
                              spreadRadius: 30,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 720),
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF171717) : Colors.white,
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.white10 : Colors.black12,
                        blurRadius: 40,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Resume\nMatch Score',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          height: 0.95,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Enter your skills and check how well your profile matches fresher job requirements.',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 16,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: skillsController,
                        minLines: 4,
                        maxLines: 6,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Example: Flutter, Firebase, Python, SQL, Java, Communication',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF0F0F0F)
                              : Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: calculateScore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDark ? Colors.white : Colors.black,
                            foregroundColor:
                                isDark ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Check Resume Score',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      if (checked) ...[
                        const SizedBox(height: 34),
                        Center(
                          child: TweenAnimationBuilder(
                            tween: IntTween(begin: 0, end: score),
                            duration: const Duration(milliseconds: 900),
                            builder: (context, value, child) {
                              return Text(
                                '$value%',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Profile Match Score',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Missing / Improve These Skills',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: missingSkills.isEmpty
                              ? [
                                  chip('Great match!', isDark),
                                ]
                              : missingSkills
                                  .map((skill) => chip(skill, isDark))
                                  .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget chip(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black12,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}