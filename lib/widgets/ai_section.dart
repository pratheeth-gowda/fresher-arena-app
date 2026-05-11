import 'dart:ui';

import 'package:flutter/material.dart';

import '../pages/resume_score_page.dart';

class AiSection extends StatelessWidget {
  final bool isDark;

  const AiSection({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.92, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 12,
                sigmaY: 12,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color:
                        isDark ? Colors.white10 : Colors.black12,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDark ? Colors.white10 : Colors.black12,
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [

                    Container(
                      width: 100,
                      height: 100,
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
                                  Colors.grey.shade800,
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.white24
                                : Colors.black26,
                            blurRadius: 25,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color:
                            isDark ? Colors.black : Colors.white,
                        size: 42,
                      ),
                    ),

                    const SizedBox(width: 28),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: isDark
                                    ? [
                                        Colors.white,
                                        Colors.grey.shade400,
                                      ]
                                    : [
                                        Colors.black,
                                        Colors.grey.shade700,
                                      ],
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'AI Resume Assistant',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Text(
                            'Analyze your resume, improve ATS score and discover better opportunities using AI-powered suggestions.',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                              height: 1.8,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(18),
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
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black26,
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ResumeScorePage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.transparent,
                                shadowColor:
                                    Colors.transparent,
                                foregroundColor:
                                    isDark
                                        ? Colors.black
                                        : Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 26,
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                'Try AI Features',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}