import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class InterviewPage extends StatefulWidget {
  const InterviewPage({super.key});

  @override
  State<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends State<InterviewPage>
    with SingleTickerProviderStateMixin {
  String selectedRole = 'Software';
  int currentQuestion = 0;

  late AnimationController glowController;

  final Map<String, List<Map<String, String>>> questions = {
    'Software': [
      {
        'q': 'Tell me about yourself.',
        'tip':
            'Start with your education, skills, projects, internship and career goal.',
      },
      {
        'q': 'What is OOP?',
        'tip':
            'Explain Object-Oriented Programming using class, object, inheritance, polymorphism, abstraction and encapsulation.',
      },
      {
        'q': 'What projects have you done?',
        'tip':
            'Explain FresherArena, Firebase, authentication, ATS score and job matching features.',
      },
      {
        'q': 'Why should we hire you?',
        'tip':
            'Mention learning ability, project experience, communication and problem-solving skills.',
      },
    ],
    'Data Analyst': [
      {
        'q': 'What is data cleaning?',
        'tip':
            'Explain removing duplicates, missing values, wrong formats and preparing data for analysis.',
      },
      {
        'q': 'What is SQL used for?',
        'tip':
            'SQL is used to store, retrieve, filter and analyze data from databases.',
      },
      {
        'q': 'What are charts used for?',
        'tip':
            'Charts help visualize patterns, comparisons and trends in data.',
      },
      {
        'q': 'What is your strength as a data analyst?',
        'tip':
            'Mention attention to detail, logical thinking and ability to find insights.',
      },
    ],
    'HR': [
      {
        'q': 'Why do you want this job?',
        'tip':
            'Connect your interest, skills and career growth with the company role.',
      },
      {
        'q': 'What are your strengths?',
        'tip':
            'Choose 2–3 strengths like communication, teamwork, discipline and learning ability.',
      },
      {
        'q': 'What is your weakness?',
        'tip':
            'Pick a safe weakness and explain how you are improving it.',
      },
      {
        'q': 'Where do you see yourself in 5 years?',
        'tip':
            'Say you want to grow professionally and contribute to the company.',
      },
    ],
    'Operations': [
      {
        'q': 'What is operations management?',
        'tip':
            'Explain managing processes, people, resources and efficiency.',
      },
      {
        'q': 'How do you handle pressure?',
        'tip':
            'Mention prioritizing tasks, staying calm and communicating clearly.',
      },
      {
        'q': 'What is teamwork?',
        'tip':
            'Teamwork means coordinating with others to achieve a common goal.',
      },
      {
        'q': 'Why are reports important?',
        'tip':
            'Reports help track performance, identify issues and support decisions.',
      },
    ],
  };

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    glowController.dispose();
    super.dispose();
  }

  void nextQuestion() {
    final roleQuestions = questions[selectedRole] ?? [];

    setState(() {
      currentQuestion = (currentQuestion + 1) % roleQuestions.length;
    });
  }

  void previousQuestion() {
    final roleQuestions = questions[selectedRole] ?? [];

    setState(() {
      currentQuestion =
          currentQuestion == 0 ? roleQuestions.length - 1 : currentQuestion - 1;
    });
  }

  Color pageBg(bool isDark) {
    return isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final roleQuestions = questions[selectedRole] ?? [];
    final item = roleQuestions[currentQuestion];

    return Scaffold(
      backgroundColor: pageBg(isDark),
      appBar: AppBar(
        backgroundColor: pageBg(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text(
          'AI Interview Coach',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: glowController,
                  builder: (context, child) {
                    return Positioned(
                      right: 20 + sin(glowController.value * pi) * 20,
                      top: 80,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heroCard(isDark),
                    const SizedBox(height: 24),
                    roleSelector(isDark),
                    const SizedBox(height: 24),
                    questionCard(isDark, item),
                    const SizedBox(height: 24),
                    tipsGrid(isDark),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget heroCard(bool isDark) {
    return glassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.record_voice_over_rounded,
            size: 48,
            color: isDark ? Colors.white : Colors.black,
          ),
          const SizedBox(height: 18),
          Text(
            'AI Interview Coach',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 38,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Practice fresher interview questions, role-based HR questions, technical questions and answer tips in a game-style format.',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 17,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget roleSelector(bool isDark) {
    final roles = questions.keys.toList();

    return glassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Interview Role',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: roles.map((role) {
              final selected = selectedRole == role;

              return ChoiceChip(
                label: Text(role),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    selectedRole = role;
                    currentQuestion = 0;
                  });
                },
                selectedColor: isDark ? Colors.white : Colors.black,
                backgroundColor:
                    isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                labelStyle: TextStyle(
                  color: selected
                      ? isDark
                          ? Colors.black
                          : Colors.white
                      : isDark
                          ? Colors.white
                          : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget questionCard(bool isDark, Map<String, String> item) {
    final roleQuestions = questions[selectedRole] ?? [];

    return glassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              levelBadge(isDark),
              const Spacer(),
              Text(
                '${currentQuestion + 1}/${roleQuestions.length}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            item['q'] ?? '',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 30,
              height: 1.35,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 26),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.greenAccent.withOpacity(0.45),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb,
                  color: Colors.greenAccent,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item['tip'] ?? '',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: previousQuestion,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : Colors.black,
                    side: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: nextQuestion,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget tipsGrid(bool isDark) {
    final tips = [
      ['Confidence', 'Speak clearly and maintain positive body language.'],
      ['Resume', 'Know every project and skill written in your resume.'],
      ['Company', 'Research company services, values and recent work.'],
      ['Examples', 'Use real examples from projects, internship and college.'],
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tips.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.3,
      ),
      itemBuilder: (context, index) {
        final tip = tips[index];

        return glassCard(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tip[0],
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tip[1],
                style: const TextStyle(
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget levelBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
      ),
      child: Text(
        selectedRole,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
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
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.78),
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
          child: child,
        ),
      ),
    );
  }
}