import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  int score = 0;
  int coins = 0;
  int streak = 0;
  int selectedAnswer = -1;
  bool answered = false;
  int secondsLeft = 20;
  Timer? timer;

  late AnimationController glowController;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Which skill is most important for a Software Engineer?',
      'options': ['Cooking', 'Programming', 'Singing', 'Driving'],
      'answer': 1,
    },
    {
      'question': 'What does ATS stand for?',
      'options': [
        'Application Tracking System',
        'Applicant Tracking System',
        'Auto Text Scanner',
        'Advanced Tech Software'
      ],
      'answer': 1,
    },
    {
      'question': 'Which one is used for databases?',
      'options': ['SQL', 'HTML', 'CSS', 'Figma'],
      'answer': 0,
    },
    {
      'question': 'Which section is important in a fresher resume?',
      'options': ['Projects', 'Random quotes', 'Movies', 'Games'],
      'answer': 0,
    },
    {
      'question': 'Which is a soft skill?',
      'options': ['Flutter', 'Communication', 'Firebase', 'Python'],
      'answer': 1,
    },
    {
      'question': 'What should you do before an interview?',
      'options': [
        'Ignore the company',
        'Research the company',
        'Sleep during interview',
        'Skip resume'
      ],
      'answer': 1,
    },
    {
      'question': 'Which platform is used for version control?',
      'options': ['GitHub', 'Canva', 'Instagram', 'Chrome'],
      'answer': 0,
    },
    {
      'question': 'Which keyword suits a Data Analyst role?',
      'options': ['SQL', 'Painting', 'Acting', 'Music'],
      'answer': 0,
    },
  ];

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    glowController.dispose();
    super.dispose();
  }

  void startTimer() {
    timer?.cancel();
    secondsLeft = 20;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft == 0) {
        timer.cancel();
        nextQuestion();
      } else {
        setState(() {
          secondsLeft--;
        });
      }
    });
  }

  void checkAnswer(int index) {
    if (answered) return;

    final correctAnswer = questions[currentIndex]['answer'];

    setState(() {
      selectedAnswer = index;
      answered = true;

      if (index == correctAnswer) {
        score++;
        streak++;
        coins += 10 + (streak * 2);
      } else {
        streak = 0;
      }
    });

    timer?.cancel();

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) nextQuestion();
    });
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = -1;
        answered = false;
      });

      startTimer();
    } else {
      timer?.cancel();
      setState(() {
        currentIndex = questions.length;
      });
    }
  }

  void restartQuiz() {
    setState(() {
      currentIndex = 0;
      score = 0;
      coins = 0;
      streak = 0;
      selectedAnswer = -1;
      answered = false;
    });

    startTimer();
  }

  String rankTitle() {
    final percentage = (score / questions.length) * 100;

    if (percentage >= 85) return 'Career Champion 🏆';
    if (percentage >= 65) return 'Job Ready Star ⭐';
    if (percentage >= 45) return 'Rising Fresher 🚀';
    return 'Keep Practicing 💪';
  }

  Color optionColor(int index, bool isDark) {
    if (!answered) {
      return isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04);
    }

    final correctAnswer = questions[currentIndex]['answer'];

    if (index == correctAnswer) {
      return Colors.greenAccent.withOpacity(0.22);
    }

    if (index == selectedAnswer && index != correctAnswer) {
      return Colors.redAccent.withOpacity(0.22);
    }

    return isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04);
  }

  Color pageBg(bool isDark) {
    return isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
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
          'Fresher Quiz Game',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: currentIndex >= questions.length
          ? resultScreen(isDark)
          : quizScreen(isDark),
    );
  }

  Widget quizScreen(bool isDark) {
    final question = questions[currentIndex];
    final progress = (currentIndex + 1) / questions.length;
    final timerProgress = secondsLeft / 20;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: glowController,
                builder: (context, child) {
                  return Positioned(
                    right: 20 + sin(glowController.value * pi) * 20,
                    top: 40,
                    child: Container(
                      width: 180,
                      height: 180,
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
                children: [
                  gameHeader(isDark, progress),
                  const SizedBox(height: 22),
                  glassCard(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            levelBadge(isDark),
                            const Spacer(),
                            timerBadge(isDark),
                          ],
                        ),
                        const SizedBox(height: 18),
                        LinearProgressIndicator(
                          value: timerProgress,
                          minHeight: 9,
                          borderRadius: BorderRadius.circular(20),
                          color: secondsLeft <= 5
                              ? Colors.redAccent
                              : Colors.greenAccent,
                          backgroundColor: isDark ? Colors.white12 : Colors.black12,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          question['question'],
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ...List.generate(question['options'].length, (index) {
                          return optionTile(
                            index: index,
                            text: question['options'][index],
                            isDark: isDark,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget gameHeader(bool isDark, double progress) {
    return glassCard(
      isDark: isDark,
      child: Column(
        children: [
          Row(
            children: [
              statPill('Score', '$score/${questions.length}', Icons.star, isDark),
              const SizedBox(width: 10),
              statPill('Coins', '$coins', Icons.monetization_on, isDark),
              const SizedBox(width: 10),
              statPill('Streak', '$streak', Icons.local_fire_department, isDark),
            ],
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(20),
            color: isDark ? Colors.white : Colors.black,
            backgroundColor: isDark ? Colors.white12 : Colors.black12,
          ),
        ],
      ),
    );
  }

  Widget optionTile({
    required int index,
    required String text,
    required bool isDark,
  }) {
    final letters = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      onTap: () => checkAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: optionColor(index, isDark),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selectedAnswer == index
                ? isDark
                    ? Colors.white
                    : Colors.black
                : isDark
                    ? Colors.white12
                    : Colors.black12,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isDark ? Colors.white : Colors.black,
              child: Text(
                letters[index],
                style: TextStyle(
                  color: isDark ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget resultScreen(bool isDark) {
    final percentage = ((score / questions.length) * 100).round();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: glassCard(
            isDark: isDark,
            child: Column(
              children: [
                const Text(
                  '🎮',
                  style: TextStyle(fontSize: 72),
                ),
                const SizedBox(height: 10),
                Text(
                  rankTitle(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You scored $score out of ${questions.length}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: percentage >= 65
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    statPill('Coins Earned', '$coins', Icons.monetization_on, isDark),
                    statPill('Best Streak', '$streak', Icons.local_fire_department, isDark),
                    statPill('Level', percentage >= 65 ? 'Pro' : 'Beginner', Icons.emoji_events, isDark),
                  ],
                ),
                const SizedBox(height: 34),
                ElevatedButton.icon(
                  onPressed: restartQuiz,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget levelBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
      ),
      child: Text(
        'Level ${currentIndex + 1}/${questions.length}',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget timerBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: secondsLeft <= 5
            ? Colors.redAccent.withOpacity(0.15)
            : Colors.greenAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: secondsLeft <= 5
              ? Colors.redAccent.withOpacity(0.5)
              : Colors.greenAccent.withOpacity(0.5),
        ),
      ),
      child: Text(
        '$secondsLeft sec',
        style: TextStyle(
          color: secondsLeft <= 5 ? Colors.redAccent : Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget statPill(String title, String value, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDark ? Colors.white : Colors.black),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    title,
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
      ),
    );
  }

  Widget glassCard({
    required bool isDark,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black12,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.white10 : Colors.black12,
                blurRadius: 35,
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