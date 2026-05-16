import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  Color pageBg(bool isDark) {
    return isDark
        ? const Color(0xFF050505)
        : const Color(0xFFF5F5F5);
  }

  IconData iconForType(String type) {
    switch (type) {
      case 'job':
        return Icons.work_outline;

      case 'success':
        return Icons.check_circle_outline;

      case 'ai':
        return Icons.psychology_alt_outlined;

      case 'warning':
        return Icons.warning_amber_outlined;

      default:
        return Icons.notifications_none;
    }
  }

  Color colorForType(String type) {
    switch (type) {
      case 'job':
        return Colors.blueAccent;

      case 'success':
        return Colors.greenAccent;

      case 'ai':
        return Colors.purpleAccent;

      case 'warning':
        return Colors.orangeAccent;

      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      backgroundColor: pageBg(isDark),
      appBar: AppBar(
        backgroundColor: pageBg(isDark),
        elevation: 0,
        iconTheme: IconThemeData(
          color:
              isDark ? Colors.white : Colors.black,
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color:
                isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('notifications')
                .orderBy(
                  'createdAt',
                  descending: true,
                )
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final docs =
              snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(
                  color: isDark
                      ? Colors.white
                      : Colors.black,
                  fontSize: 20,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(22),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 950,
                ),
                child: Column(
                  children: docs.map((doc) {
                    final data =
                        doc.data()
                            as Map<String, dynamic>;

                    final type =
                        data['type'] ??
                            'default';

                    final color =
                        colorForType(type);

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 18,
                      ),
                      child: glassCard(
                        isDark: isDark,
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor:
                                  color.withOpacity(
                                      0.14),
                              child: Icon(
                                iconForType(type),
                                color: color,
                              ),
                            ),

                            const SizedBox(
                                width: 18),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    data['title'] ??
                                        '',
                                    style:
                                        TextStyle(
                                      color: isDark
                                          ? Colors
                                              .white
                                          : Colors
                                              .black,
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 8),

                                  Text(
                                    data['message'] ??
                                        '',
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors
                                              .grey,
                                      height: 1.6,
                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 14),

                                  Row(
                                    children: [
                                      Icon(
                                        Icons
                                            .access_time,
                                        color:
                                            Colors
                                                .grey,
                                        size: 16,
                                      ),

                                      const SizedBox(
                                          width:
                                              6),

                                      Text(
                                        'Live Notification',
                                        style:
                                            const TextStyle(
                                          color: Colors
                                              .grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget glassCard({
    required bool isDark,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white
                    .withOpacity(0.055)
                : Colors.white
                    .withOpacity(0.84),
            borderRadius:
                BorderRadius.circular(
                    30),
            border: Border.all(
              color: isDark
                  ? Colors.white12
                  : Colors.black12,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.white10
                    : Colors.black12,
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