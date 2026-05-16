import 'dart:ui';

import 'package:flutter/material.dart';

import '../pages/job_match_page.dart';
import '../pages/resume_builder_page.dart';
import '../pages/resume_score_page.dart';

class AiSection extends StatelessWidget {
  final bool isDark;

  const AiSection({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 14,
                sigmaY: 14,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(34),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 850;

                    return Flex(
                      direction: isMobile ? Axis.vertical : Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        animatedOrb(),
                        SizedBox(
                          width: isMobile ? 0 : 30,
                          height: isMobile ? 30 : 0,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Career Assistant',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Analyze resumes, generate ATS-friendly resumes, match your profile with jobs and improve your career chances using FresherArena AI.',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  height: 1.7,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  topButton(
                                    context,
                                    isDark,
                                    Icons.analytics_outlined,
                                    'ATS Resume Score',
                                    const ResumeScorePage(),
                                  ),
                                  topButton(
                                    context,
                                    isDark,
                                    Icons.description_outlined,
                                    'AI Resume Builder',
                                    const ResumeBuilderPage(),
                                  ),
                                  topButton(
                                    context,
                                    isDark,
                                    Icons.psychology_alt_outlined,
                                    'AI Job Match',
                                    const JobMatchPage(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  premiumTag(
                                    isDark,
                                    Icons.auto_fix_high,
                                    'ATS Optimization',
                                  ),
                                  premiumTag(
                                    isDark,
                                    Icons.description_outlined,
                                    'Resume Builder',
                                  ),
                                  premiumTag(
                                    isDark,
                                    Icons.work_outline,
                                    'Job Matching',
                                  ),
                                  premiumTag(
                                    isDark,
                                    Icons.lightbulb_outline,
                                    'AI Suggestions',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget animatedOrb() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.black,
                  Colors.grey.shade800,
                ]
              : [
                  Colors.white,
                  Colors.grey.shade300,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.white10 : Colors.black12,
            blurRadius: 28,
          ),
        ],
      ),
      child: Icon(
        Icons.auto_awesome,
        color: isDark ? Colors.white : Colors.black,
        size: 48,
      ),
    );
  }

  Widget topButton(
    BuildContext context,
    bool isDark,
    IconData icon,
    String text,
    Widget page,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    Colors.black,
                    Colors.grey.shade800,
                  ]
                : [
                    Colors.white,
                    Colors.grey.shade300,
                  ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.white10 : Colors.black12,
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget premiumTag(
    bool isDark,
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}