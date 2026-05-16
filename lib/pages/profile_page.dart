import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'achievements_page.dart';
import 'admin_page.dart';
import 'career_roadmap_page.dart';
import 'login_page.dart';
import 'resume_upload_page.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const ProfilePage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String adminEmail = 'pratheethnvn@gmail.com';

  bool uploadingImage = false;
  String photoUrl = '';

  User? get user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadProfilePhoto();
  }

  Color pageBg(bool isDark) {
    return isDark ? const Color(0xFF050505) : const Color(0xFFF5F5F5);
  }

  Future<void> loadProfilePhoto() async {
    final currentUser = user;
    if (currentUser == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!mounted) return;

    setState(() {
      photoUrl = (doc.data()?['photoUrl'] ?? '').toString();
    });
  }

  Future<void> uploadProfilePhoto() async {
    final currentUser = user;

    if (currentUser == null) {
      showMessage('Please login first.');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    final Uint8List bytes = result.files.single.bytes!;

    setState(() {
      uploadingImage = true;
    });

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${currentUser.uid}.jpg');

      await ref.putData(bytes);

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
        'photoUrl': url,
        'email': currentUser.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        photoUrl = url;
        uploadingImage = false;
      });

      showMessage('Profile picture updated.');
    } catch (e) {
      setState(() {
        uploadingImage = false;
      });

      showMessage('Image upload failed.');
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
        ),
      ),
      (route) => false,
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> savedJobsStream() {
    final currentUser = user;
    if (currentUser == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('saved_jobs')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> appliedJobsStream() {
    final currentUser = user;
    if (currentUser == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('applied_jobs')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> atsHistoryStream() {
    final currentUser = user;
    if (currentUser == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('ats_history')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = user;

    return Scaffold(
      backgroundColor: pageBg(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profileHero(isDark, currentUser),
                  const SizedBox(height: 24),
                  statsSection(isDark),
                  const SizedBox(height: 24),
                  shortcutsSection(isDark, currentUser),
                  const SizedBox(height: 24),
                  recentAppliedJobs(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget profileHero(bool isDark, User? currentUser) {
    return glassCard(
      isDark: isDark,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;

          return Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 58,
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    backgroundImage:
                        photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                    child: photoUrl.isEmpty
                        ? Text(
                            currentUser?.email != null
                                ? currentUser!.email![0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: isDark ? Colors.black : Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: uploadingImage ? null : uploadProfilePhoto,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.greenAccent,
                        child: uploadingImage
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 18,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: isMobile ? 0 : 24,
                height: isMobile ? 18 : 0,
              ),
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Column(
                  crossAxisAlignment:
                      isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Career Profile',
                      textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentUser?.email ?? 'No email found',
                      textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    premiumTag(
                      isDark,
                      currentUser?.email == adminEmail
                          ? 'Admin Account'
                          : 'Student Account',
                      currentUser?.email == adminEmail
                          ? Icons.admin_panel_settings
                          : Icons.school,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: isMobile ? 0 : 18,
                height: isMobile ? 18 : 0,
              ),
              ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 17,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget statsSection(bool isDark) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: savedJobsStream(),
      builder: (context, savedSnapshot) {
        final savedCount = savedSnapshot.data?.docs.length ?? 0;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: appliedJobsStream(),
          builder: (context, appliedSnapshot) {
            final appliedCount = appliedSnapshot.data?.docs.length ?? 0;

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: atsHistoryStream(),
              builder: (context, atsSnapshot) {
                final atsCount = atsSnapshot.data?.docs.length ?? 0;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 750;

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isMobile ? 1 : 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isMobile ? 4.0 : 1.65,
                      children: [
                        statCard(
                          isDark: isDark,
                          title: 'Saved Jobs',
                          value: savedCount.toString(),
                          icon: Icons.bookmark_border,
                        ),
                        statCard(
                          isDark: isDark,
                          title: 'Applied Jobs',
                          value: appliedCount.toString(),
                          icon: Icons.check_circle_outline,
                        ),
                        statCard(
                          isDark: isDark,
                          title: 'ATS Results',
                          value: atsCount.toString(),
                          icon: Icons.analytics_outlined,
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget shortcutsSection(bool isDark, User? currentUser) {
    final isAdmin = currentUser?.email == adminEmail;

    return glassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Career Tools',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              shortcutButton(
                isDark: isDark,
                icon: Icons.upload_file,
                title: 'Upload Resume',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResumeUploadPage(),
                    ),
                  );
                },
              ),
              shortcutButton(
                isDark: isDark,
                icon: Icons.emoji_events,
                title: 'Achievements',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AchievementsPage(),
                    ),
                  );
                },
              ),
              shortcutButton(
                isDark: isDark,
                icon: Icons.route,
                title: 'Career Roadmap',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CareerRoadmapPage(),
                    ),
                  );
                },
              ),
              if (isAdmin)
                shortcutButton(
                  isDark: isDark,
                  icon: Icons.admin_panel_settings,
                  title: 'Admin Panel',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminPage(),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget recentAppliedJobs(bool isDark) {
    return glassCard(
      isDark: isDark,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: appliedJobsStream(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Applied Jobs',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              if (docs.isEmpty)
                const Text(
                  'No applied jobs yet. Apply to a job and it will appear here.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ...docs.take(5).map((doc) {
                  final data = doc.data();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          child: Text(
                            '${data['company'] ?? 'J'}'[0].toUpperCase(),
                            style: TextStyle(
                              color: isDark ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['role'] ?? 'Job Role',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${data['company'] ?? ''} • ${data['location'] ?? ''}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.greenAccent.withOpacity(0.45),
                            ),
                          ),
                          child: const Text(
                            'Applied',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget statCard({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return glassCard(
      isDark: isDark,
      child: Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: isDark ? Colors.white10 : Colors.black12,
            child: Icon(
              icon,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget shortcutButton({
    required bool isDark,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(title),
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
    );
  }

  Widget premiumTag(bool isDark, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
                ? Colors.white.withOpacity(0.055)
                : Colors.white.withOpacity(0.84),
            borderRadius: BorderRadius.circular(30),
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