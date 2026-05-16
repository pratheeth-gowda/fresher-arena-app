import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/job.dart';

class JobDetailsPage extends StatefulWidget {
  final Job job;

  const JobDetailsPage({
    super.key,
    required this.job,
  });

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  bool isSaved = false;
  bool isApplied = false;
  String resumeUrl = '';

  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadStatus();
  }

  Future<void> loadStatus() async {
    final user = currentUser;

    if (user == null) return;

    final savedDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_jobs')
        .doc(widget.job.id)
        .get();

    final appliedDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('applied_jobs')
        .doc(widget.job.id)
        .get();

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    setState(() {
      isSaved = savedDoc.exists;
      isApplied = appliedDoc.exists;
      resumeUrl = (userDoc.data()?['resumeUrl'] ?? '').toString();
    });
  }

  Future<void> toggleSaveJob() async {
    final user = currentUser;

    if (user == null) {
      showToast('Please login first.');
      return;
    }

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_jobs')
        .doc(widget.job.id);

    if (isSaved) {
      await ref.delete();
      setState(() => isSaved = false);
      showToast('Job removed from saved.');
    } else {
      await ref.set({
        'jobId': widget.job.id,
        'role': widget.job.role,
        'company': widget.job.company,
        'location': widget.job.location,
        'salary': widget.job.salary,
        'type': widget.job.type,
        'description': widget.job.description,
        'applyLink': widget.job.applyLink,
      });

      setState(() => isSaved = true);
      showToast('Job saved successfully.');
    }
  }

  Future<void> applyNow() async {
    final user = currentUser;

    if (user == null) {
      showToast('Please login first.');
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userResumeUrl = (userDoc.data()?['resumeUrl'] ?? '').toString();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('applied_jobs')
        .doc(widget.job.id)
        .set({
      'jobId': widget.job.id,
      'role': widget.job.role,
      'company': widget.job.company,
      'location': widget.job.location,
      'salary': widget.job.salary,
      'type': widget.job.type,
      'description': widget.job.description,
      'applyLink': widget.job.applyLink,
      'resumeUrl': userResumeUrl,
      'userEmail': user.email,
      'status': 'Applied',
      'appliedAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      isApplied = true;
      resumeUrl = userResumeUrl;
    });

    final Uri url = Uri.parse(widget.job.applyLink);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }

    showToast('Application tracked successfully.');
  }

  Future<void> openDirections() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${widget.job.latitude},${widget.job.longitude}';

    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  void showToast(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color pageBg(bool isDark) {
    return isDark ? const Color(0xFF050505) : const Color(0xFFF5F5F5);
  }

  String companyLogoUrl(String company) {
    final c = company.toLowerCase();

    if (c.contains('tcs')) return 'https://logo.clearbit.com/tcs.com';
    if (c.contains('infosys')) return 'https://logo.clearbit.com/infosys.com';
    if (c.contains('accenture')) {
      return 'https://logo.clearbit.com/accenture.com';
    }
    if (c.contains('wipro')) return 'https://logo.clearbit.com/wipro.com';

    return 'https://ui-avatars.com/api/?name=$company&background=ffffff&color=000000&bold=true';
  }

  String aboutCompany(String company) {
    final c = company.toLowerCase();

    if (c.contains('tcs')) {
      return 'Tata Consultancy Services is a global IT services and consulting company helping enterprises with technology, digital transformation, business solutions, and innovation.';
    }

    if (c.contains('infosys')) {
      return 'Infosys is a global technology and consulting company known for software development, digital services, cloud solutions, and business transformation.';
    }

    if (c.contains('accenture')) {
      return 'Accenture is a global professional services company specializing in technology, consulting, cloud, digital transformation, and business solutions.';
    }

    if (c.contains('wipro')) {
      return 'Wipro is a global IT, consulting, and business process services company focused on innovation, engineering, and client-driven digital solutions.';
    }

    return '$company offers fresher-friendly career opportunities with learning, training, and real-world professional exposure.';
  }

  String categoryForCompany(String company) {
    final c = company.toLowerCase();

    if (c.contains('tcs')) return 'IT Services';
    if (c.contains('infosys')) return 'Technology';
    if (c.contains('accenture')) return 'Consulting';
    if (c.contains('wipro')) return 'IT Solutions';

    return 'Hiring';
  }

  List<Map<String, Object>> companyStats(String company) {
    final c = company.toLowerCase();

    if (c.contains('tcs')) {
      return [
        {'icon': Icons.groups, 'value': '600K+', 'label': 'Employees'},
        {'icon': Icons.public, 'value': '55+', 'label': 'Countries'},
        {'icon': Icons.trending_up, 'value': 'Global', 'label': 'Leader'},
        {'icon': Icons.calendar_month, 'value': '1968', 'label': 'Founded'},
      ];
    }

    if (c.contains('infosys')) {
      return [
        {'icon': Icons.groups, 'value': '300K+', 'label': 'Employees'},
        {'icon': Icons.public, 'value': '50+', 'label': 'Countries'},
        {'icon': Icons.trending_up, 'value': 'Global', 'label': 'Tech'},
        {'icon': Icons.calendar_month, 'value': '1981', 'label': 'Founded'},
      ];
    }

    if (c.contains('accenture')) {
      return [
        {'icon': Icons.groups, 'value': '700K+', 'label': 'Employees'},
        {'icon': Icons.public, 'value': '120+', 'label': 'Countries'},
        {'icon': Icons.trending_up, 'value': 'Global', 'label': 'Consulting'},
        {'icon': Icons.calendar_month, 'value': '1989', 'label': 'Founded'},
      ];
    }

    if (c.contains('wipro')) {
      return [
        {'icon': Icons.groups, 'value': '240K+', 'label': 'Employees'},
        {'icon': Icons.public, 'value': '60+', 'label': 'Countries'},
        {'icon': Icons.trending_up, 'value': 'Global', 'label': 'IT'},
        {'icon': Icons.calendar_month, 'value': '1945', 'label': 'Founded'},
      ];
    }

    return [
      {'icon': Icons.groups, 'value': 'Growing', 'label': 'Team'},
      {'icon': Icons.public, 'value': 'India', 'label': 'Location'},
      {'icon': Icons.trending_up, 'value': 'Active', 'label': 'Hiring'},
      {'icon': Icons.school, 'value': 'Freshers', 'label': 'Friendly'},
    ];
  }

  List<String> roleHighlights(Job job) {
    final text = '${job.role} ${job.description}'.toLowerCase();

    if (text.contains('software') || text.contains('developer')) {
      return [
        'Work on real-world software development tasks.',
        'Improve coding, debugging, and project-building skills.',
        'Good opportunity for freshers interested in technology.',
        'Build professional experience with structured learning.',
      ];
    }

    if (text.contains('bps') || text.contains('operations')) {
      return [
        'Entry-level role with structured training.',
        'Build communication and business process skills.',
        'Suitable for freshers starting a corporate career.',
        'Gain exposure to customer support and operations.',
      ];
    }

    if (text.contains('data')) {
      return [
        'Work with business data and reporting tasks.',
        'Improve analytical and problem-solving skills.',
        'Good fit for freshers interested in data careers.',
        'Learn to convert data into useful insights.',
      ];
    }

    return [
      'Fresher-friendly opportunity with learning scope.',
      'Gain practical exposure in a professional environment.',
      'Build career experience with a reputed company.',
      'Improve confidence for future job opportunities.',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: pageBg(isDark),
      appBar: AppBar(
        backgroundColor: pageBg(isDark),
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
        actions: [
          IconButton(
            onPressed: toggleSaveJob,
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved
                  ? Colors.amber
                  : isDark
                      ? Colors.white
                      : Colors.black,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerCard(isDark),
                const SizedBox(height: 24),
                overviewGrid(isDark),
                const SizedBox(height: 24),
                aboutCard(isDark),
                const SizedBox(height: 24),
                roleHighlightsCard(isDark),
                const SizedBox(height: 24),
                resumeStatusCard(isDark),
                const SizedBox(height: 24),
                mapCard(isDark),
                const SizedBox(height: 24),
                actionButtons(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget headerCard(bool isDark) {
    return glassCard(
      isDark: isDark,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 720;

          return Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 115,
                height: 115,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.white10 : Colors.black12,
                      blurRadius: 26,
                    ),
                  ],
                ),
                child: Image.network(
                  companyLogoUrl(widget.job.company),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        widget.job.company.isNotEmpty
                            ? widget.job.company[0].toUpperCase()
                            : 'J',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: isMobile ? 0 : 24,
                height: isMobile ? 20 : 0,
              ),
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Column(
                  crossAxisAlignment:
                      isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.role,
                      textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
                      children: [
                        Text(
                          widget.job.company,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Icon(
                          Icons.verified,
                          color: Colors.greenAccent,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
                      children: [
                        tagChip(isDark, categoryForCompany(widget.job.company)),
                        tagChip(isDark, 'Fresher'),
                        tagChip(isDark, widget.job.type),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: isMobile ? 0 : 18,
                height: isMobile ? 18 : 0,
              ),
              if (isApplied)
                statusBadge(
                  'Applied',
                  Icons.check_circle,
                  Colors.greenAccent,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget overviewGrid(bool isDark) {
    final items = [
      [Icons.location_on_outlined, 'Location', widget.job.location],
      [Icons.work_outline, 'Job Type', widget.job.type],
      [Icons.currency_rupee, 'Salary', widget.job.salary],
      [
        Icons.picture_as_pdf,
        'Resume',
        resumeUrl.isEmpty ? 'Not uploaded' : 'Attached'
      ],
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile ? 4.2 : 1.65,
          ),
          itemBuilder: (context, index) {
            final item = items[index];

            return glassCard(
              isDark: isDark,
              padding: const EdgeInsets.all(20),
              radius: 24,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    child: Icon(
                      item[0] as IconData,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item[2] as String,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          item[1] as String,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget aboutCard(bool isDark) {
    return glassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionHeader(isDark, Icons.business, 'About the Company'),
          const SizedBox(height: 16),
          Text(
            aboutCompany(widget.job.company),
            style: const TextStyle(
              color: Colors.grey,
              height: 1.7,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: companyStats(widget.job.company).map((item) {
              return statBox(
                isDark,
                item['icon'] as IconData,
                item['value'] as String,
                item['label'] as String,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget roleHighlightsCard(bool isDark) {
    return glassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionHeader(isDark, Icons.star_border, 'Role Highlights'),
          const SizedBox(height: 16),
          ...roleHighlights(widget.job).map((point) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '•',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        color: Colors.grey,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget resumeStatusCard(bool isDark) {
    final hasResume = resumeUrl.isNotEmpty;

    return glassCard(
      isDark: isDark,
      borderColor: hasResume
          ? Colors.greenAccent.withOpacity(0.45)
          : Colors.orangeAccent.withOpacity(0.45),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: hasResume
                ? Colors.greenAccent.withOpacity(0.15)
                : Colors.orangeAccent.withOpacity(0.15),
            child: Icon(
              hasResume ? Icons.check_circle : Icons.warning_amber,
              color: hasResume ? Colors.greenAccent : Colors.orangeAccent,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              hasResume
                  ? 'Your resume is attached and will be visible to the recruiter after applying.'
                  : 'No resume uploaded yet. Upload your resume from Profile for better recruiter visibility.',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget mapCard(bool isDark) {
    return glassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionHeader(isDark, Icons.map_outlined, 'Company Location'),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 320,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    widget.job.latitude,
                    widget.job.longitude,
                  ),
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.fresherarena.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80,
                        height: 80,
                        point: LatLng(
                          widget.job.latitude,
                          widget.job.longitude,
                        ),
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.redAccent,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: openDirections,
            icon: const Icon(Icons.directions),
            label: const Text('Get Directions'),
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
          ),
        ],
      ),
    );
  }

  Widget actionButtons(bool isDark) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        ElevatedButton.icon(
          onPressed: applyNow,
          icon: const Icon(Icons.open_in_new),
          label: Text(isApplied ? 'Applied' : 'Apply Now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.white : Colors.black,
            foregroundColor: isDark ? Colors.black : Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: toggleSaveJob,
          icon: Icon(
            isSaved ? Icons.bookmark_remove : Icons.bookmark_add,
          ),
          label: Text(isSaved ? 'Unsave Job' : 'Save Job'),
          style: OutlinedButton.styleFrom(
            foregroundColor: isDark ? Colors.white : Colors.black,
            side: BorderSide(
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ],
    );
  }

  Widget sectionHeader(
    bool isDark,
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.greenAccent, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget tagChip(bool isDark, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget statBox(
    bool isDark,
    IconData icon,
    String value,
    String label,
  ) {
    return Container(
      width: 185,
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
          Icon(icon, color: Colors.greenAccent, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget statusBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
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
    EdgeInsets padding = const EdgeInsets.all(26),
    double radius = 30,
    Color? borderColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.055)
                : Colors.white.withOpacity(0.84),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color:
                  borderColor ?? (isDark ? Colors.white12 : Colors.black12),
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