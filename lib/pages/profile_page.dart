import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
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

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor:
          isDark
              ? const Color(0xFF0A0A0A)
              : const Color(0xFFF5F5F5),

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
                      left: floatingAnimation.value,
                      top: 20,

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
                  width: 450,

                  padding: const EdgeInsets.all(34),

                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF171717)
                        : Colors.white,

                    borderRadius:
                        BorderRadius.circular(30),

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
                    mainAxisSize: MainAxisSize.min,

                    children: [

                      CircleAvatar(
                        radius: 50,

                        backgroundColor:
                            isDark
                                ? Colors.white
                                : Colors.black,

                        child: Text(
                          user?.email != null
                              ? user!.email![0]
                                  .toUpperCase()
                              : 'U',

                          style: TextStyle(
                            color: isDark
                                ? Colors.black
                                : Colors.white,

                            fontSize: 34,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'PROFILE',

                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : Colors.black,

                          fontSize: 32,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 28),

                      buildInfoCard(
                        title: 'Email',
                        value:
                            user?.email ?? 'No Email',
                        isDark: isDark,
                        icon: Icons.mail_outline,
                      ),

                      const SizedBox(height: 18),

                      buildInfoCard(
                        title: 'User ID',
                        value: user?.uid
                                .substring(0, 12) ??
                            '',
                        isDark: isDark,
                        icon:
                            Icons.person_outline,
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          onPressed: logout,

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
                              vertical: 18,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      18),
                            ),
                          ),

                          child: const Text(
                            'Logout',

                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
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

  Widget buildInfoCard({
    required String title,
    required String value,
    required bool isDark,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F0F0F)
            : Colors.grey.shade100,

        borderRadius:
            BorderRadius.circular(22),

        border: Border.all(
          color:
              isDark
                  ? Colors.white10
                  : Colors.black12,
        ),
      ),

      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: isDark
                  ? Colors.white10
                  : Colors.black12,
            ),

            child: Icon(
              icon,

              color:
                  isDark
                      ? Colors.white
                      : Colors.black,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  value,

                  overflow:
                      TextOverflow.ellipsis,

                  style: TextStyle(
                    color: isDark
                        ? Colors.white
                        : Colors.black,

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}