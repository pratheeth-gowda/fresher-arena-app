import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/job.dart';

class JobDetailsPage extends StatefulWidget {
  final Job job;

  const JobDetailsPage({
    super.key,
    required this.job,
  });

  @override
  State<JobDetailsPage> createState() =>
      _JobDetailsPageState();
}

class _JobDetailsPageState
    extends State<JobDetailsPage>
    with SingleTickerProviderStateMixin {
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

  Future<void> applyJob() async {
    final Uri url =
        Uri.parse(widget.job.applyLink);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? const Color(0xFF0A0A0A)
              : const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor:
            isDark
                ? const Color(0xFF0A0A0A)
                : const Color(0xFFF5F5F5),

        elevation: 0,
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
                      right:
                          floatingAnimation.value,
                      top: 30,

                      child: Container(
                        width: 220,
                        height: 220,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          color: isDark
                              ? Colors.white10
                              : Colors.black12,

                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.white24
                                  : Colors.black12,

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
                  constraints:
                      const BoxConstraints(
                    maxWidth: 700,
                  ),

                  padding: const EdgeInsets.all(36),

                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF171717)
                        : Colors.white,

                    borderRadius:
                        BorderRadius.circular(34),

                    border: Border.all(
                      color: isDark
                          ? Colors.white10
                          : Colors.black12,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.white10
                            : Colors.black12,

                        blurRadius: 40,
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          CircleAvatar(
                            radius: 34,

                            backgroundColor:
                                isDark
                                    ? Colors.white
                                    : Colors.black,

                            child: Text(
                              widget.job.company[0],

                              style: TextStyle(
                                color: isDark
                                    ? Colors.black
                                    : Colors.white,

                                fontSize: 28,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(
                                  widget.job.role,

                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black,

                                    fontSize: 30,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                    height: 8),

                                Text(
                                  widget.job.company,

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 34),

                      buildInfoRow(
                        icon:
                            Icons.location_on_outlined,
                        title: 'Location',
                        value:
                            widget.job.location,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 18),

                      buildInfoRow(
                        icon: Icons.work_outline,
                        title: 'Job Type',
                        value: widget.job.type,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 18),

                      buildInfoRow(
                        icon:
                            Icons.currency_rupee,
                        title: 'Salary',
                        value:
                            widget.job.salary,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 34),

                      Text(
                        'Job Description',

                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : Colors.black,

                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        widget.job.description,

                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          height: 1.7,
                        ),
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          onPressed: applyJob,

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                isDark
                                    ? Colors.white
                                    : Colors.black,

                            foregroundColor:
                                isDark
                                    ? Colors.black
                                    : Colors.white,

                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 20,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      18),
                            ),
                          ),

                          child: const Text(
                            'Apply Now',

                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                            ),
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
  }

  Widget buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F0F0F)
            : Colors.grey.shade100,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: isDark
              ? Colors.white10
              : Colors.black12,
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(
            icon,

            color:
                isDark
                    ? Colors.white
                    : Colors.black,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: RichText(
              text: TextSpan(
                children: [

                  TextSpan(
                    text: '$title: ',

                    style: TextStyle(
                      color: isDark
                          ? Colors.white
                          : Colors.black,

                      fontWeight:
                          FontWeight.bold,

                      fontSize: 15,
                    ),
                  ),

                  TextSpan(
                    text: value,

                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}