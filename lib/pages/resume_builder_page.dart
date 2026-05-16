import 'package:flutter/material.dart';

class ResumeBuilderPage extends StatefulWidget {
  const ResumeBuilderPage({super.key});

  @override
  State<ResumeBuilderPage> createState() => _ResumeBuilderPageState();
}

class _ResumeBuilderPageState extends State<ResumeBuilderPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final summaryController = TextEditingController();
  final skillsController = TextEditingController();
  final educationController = TextEditingController();
  final projectsController = TextEditingController();
  final experienceController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    summaryController.dispose();
    skillsController.dispose();
    educationController.dispose();
    projectsController.dispose();
    experienceController.dispose();
    super.dispose();
  }

  String buildResumeText() {
    return '''
${nameController.text.trim().toUpperCase()}
${emailController.text.trim()} | ${phoneController.text.trim()} | ${locationController.text.trim()}

PROFESSIONAL SUMMARY
${summaryController.text.trim()}

SKILLS
${skillsController.text.trim()}

EDUCATION
${educationController.text.trim()}

PROJECTS
${projectsController.text.trim()}

EXPERIENCE / INTERNSHIP
${experienceController.text.trim()}
''';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text(
          'AI Resume Builder',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 850;

                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: isWide ? 1 : 0,
                      child: inputSection(isDark),
                    ),
                    SizedBox(width: isWide ? 24 : 0, height: isWide ? 0 : 24),
                    Expanded(
                      flex: isWide ? 1 : 0,
                      child: previewSection(isDark),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget inputSection(bool isDark) {
    return premiumCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Your Details',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Fill the details and FresherArena will create an ATS-friendly resume format.',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(height: 22),
          inputField('Full Name', nameController, isDark),
          inputField('Email', emailController, isDark),
          inputField('Phone', phoneController, isDark),
          inputField('Location', locationController, isDark),
          inputField('Professional Summary', summaryController, isDark, maxLines: 4),
          inputField('Skills', skillsController, isDark, maxLines: 4),
          inputField('Education', educationController, isDark, maxLines: 4),
          inputField('Projects', projectsController, isDark, maxLines: 5),
          inputField('Experience / Internship', experienceController, isDark, maxLines: 5),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Resume Preview'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget previewSection(bool isDark) {
    final resumeText = buildResumeText();

    return premiumCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Resume Preview',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark ? Colors.white : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black12),
            ),
            child: Text(
              resumeText,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                height: 1.5,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget inputField(
    String label,
    TextEditingController controller,
    bool isDark, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: (_) => setState(() {}),
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
          filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: isDark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  Widget premiumCard({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}