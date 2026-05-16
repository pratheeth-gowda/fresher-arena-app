import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController glowController;

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

  Color pageBg(bool isDark) {
    return isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
  }

  int extractSalary(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('4') && lower.contains('6')) {
      return 5;
    }

    if (lower.contains('3') && lower.contains('5')) {
      return 4;
    }

    if (lower.contains('20') && lower.contains('30')) {
      return 3;
    }

    if (lower.contains('as per')) {
      return 4;
    }

    final match = RegExp(r'\d+').firstMatch(lower);

    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 0;
    }

    return 0;
  }

  String shortCompany(String name) {
    if (name.length <= 9) return name;
    return '${name.substring(0, 8)}...';
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
        title: Text(
          'Analytics Dashboard',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Jobs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          final List<String> companies = docs.map((e) {
            final data = e.data() as Map<String, dynamic>;
            return (data['company'] ?? '').toString();
          }).toSet().toList();

          final salaries = docs.map((e) {
            final data = e.data() as Map<String, dynamic>;
            return extractSalary(data['salary'] ?? '');
          }).toList();

          final avgSalary = salaries.isEmpty
              ? 0
              : salaries.reduce((a, b) => a + b) ~/ salaries.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Stack(
                  children: [
                    AnimatedBuilder(
                      animation: glowController,
                      builder: (context, child) {
                        return Positioned(
                          right: 20 + sin(glowController.value * pi) * 20,
                          top: 50,
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
                        heroSection(
                          isDark,
                          docs.length,
                          companies.length,
                          avgSalary,
                        ),
                        const SizedBox(height: 26),
                        statsGrid(
                          isDark,
                          docs.length,
                          companies.length,
                          avgSalary,
                        ),
                        const SizedBox(height: 26),
                        salaryChart(isDark, docs),
                        const SizedBox(height: 26),
                        companyChart(isDark, companies),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget heroSection(
    bool isDark,
    int totalJobs,
    int totalCompanies,
    int avgSalary,
  ) {
    return glassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Salary & Hiring Analytics',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 38,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Real-time Firebase analytics for jobs, companies and salary insights.',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 17,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              analyticsChip(
                'Jobs',
                '$totalJobs',
                Icons.work_outline,
                isDark,
              ),
              analyticsChip(
                'Companies',
                '$totalCompanies',
                Icons.business,
                isDark,
              ),
              analyticsChip(
                'Avg Salary',
                '$avgSalary LPA',
                Icons.currency_rupee,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget statsGrid(
    bool isDark,
    int totalJobs,
    int totalCompanies,
    int avgSalary,
  ) {
    final items = [
      ['Total Jobs', totalJobs.toString(), Icons.work],
      ['Top Companies', totalCompanies.toString(), Icons.business_center],
      ['Average Salary', '$avgSalary LPA', Icons.currency_rupee],
      ['Hiring Growth', '+28%', Icons.trending_up],
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 2.1,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return glassCard(
          isDark: isDark,
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                child: Icon(
                  item[2] as IconData,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item[1] as String,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item[0] as String,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget salaryChart(
    bool isDark,
    List<QueryDocumentSnapshot> docs,
  ) {
    return glassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Salary Comparison',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Approximate salary shown in LPA for demo analytics.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 340,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: 8,
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark ? Colors.white10 : Colors.black12,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= docs.length) {
                          return const SizedBox();
                        }

                        final data =
                            docs[value.toInt()].data() as Map<String, dynamic>;

                        final company =
                            (data['company'] ?? '').toString();

                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            shortCompany(company),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                ),
                barGroups: List.generate(
                  docs.length,
                  (index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final salary = extractSalary(data['salary'] ?? '');

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: salary.toDouble().clamp(0, 8),
                          width: 38,
                          borderRadius: BorderRadius.circular(14),
                          color: isDark ? Colors.white : Colors.black,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 8,
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget companyChart(
    bool isDark,
    List<String> companies,
  ) {
    return glassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Hiring Companies',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 320,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 55,
                sections: List.generate(
                  companies.length,
                  (index) {
                    return PieChartSectionData(
                      value: 20,
                      title: shortCompany(companies[index]),
                      radius: 90,
                      titleStyle: TextStyle(
                        color: isDark ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      color: Colors.primaries[index % Colors.primaries.length],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget analyticsChip(
    String title,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black12,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            '$title: $value',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
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