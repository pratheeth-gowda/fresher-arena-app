import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final roleController = TextEditingController();
  final companyController = TextEditingController();
  final locationController = TextEditingController();
  final salaryController = TextEditingController();
  final typeController = TextEditingController();
  final descriptionController = TextEditingController();
  final applyLinkController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  bool isLoading = false;

  Color pageBg(bool isDark) {
    return isDark ? const Color(0xFF050505) : const Color(0xFFF5F5F5);
  }

  Future<void> addJob() async {
    if (roleController.text.trim().isEmpty ||
        companyController.text.trim().isEmpty) {
      showToast('Role and Company are required.');
      return;
    }

    setState(() => isLoading = true);

    await FirebaseFirestore.instance.collection('Jobs').add({
      'role': roleController.text.trim(),
      'company': companyController.text.trim(),
      'location': locationController.text.trim(),
      'salary': salaryController.text.trim(),
      'type': typeController.text.trim(),
      'description': descriptionController.text.trim(),
      'applyLink': applyLinkController.text.trim(),
      'latitude':
          double.tryParse(latitudeController.text.trim()) ?? 12.9716,
      'longitude':
          double.tryParse(longitudeController.text.trim()) ?? 77.5946,
      'createdAt': FieldValue.serverTimestamp(),
    });

    clearControllers();

    setState(() => isLoading = false);

    showToast('Job added successfully.');
  }

  Future<void> deleteJob(String id) async {
    await FirebaseFirestore.instance.collection('Jobs').doc(id).delete();

    showToast('Job deleted.');
  }

  Future<void> updateJob({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final role = TextEditingController(text: data['role']);
    final company = TextEditingController(text: data['company']);
    final location = TextEditingController(text: data['location']);
    final salary = TextEditingController(text: data['salary']);
    final type = TextEditingController(text: data['type']);
    final description = TextEditingController(text: data['description']);
    final applyLink = TextEditingController(text: data['applyLink']);

    await showDialog(
      context: context,
      builder: (context) {
        final isDark =
            Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor:
              isDark ? const Color(0xFF111111) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            'Edit Job',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  adminField(role, 'Role'),
                  adminField(company, 'Company'),
                  adminField(location, 'Location'),
                  adminField(salary, 'Salary'),
                  adminField(type, 'Type'),
                  adminField(description, 'Description', maxLines: 5),
                  adminField(applyLink, 'Apply Link'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('Jobs')
                    .doc(id)
                    .update({
                  'role': role.text.trim(),
                  'company': company.text.trim(),
                  'location': location.text.trim(),
                  'salary': salary.text.trim(),
                  'type': type.text.trim(),
                  'description': description.text.trim(),
                  'applyLink': applyLink.text.trim(),
                });

                if (mounted) {
                  Navigator.pop(context);
                }

                showToast('Job updated successfully.');
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void clearControllers() {
    roleController.clear();
    companyController.clear();
    locationController.clear();
    salaryController.clear();
    typeController.clear();
    descriptionController.clear();
    applyLinkController.clear();
    latitudeController.clear();
    longitudeController.clear();
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: pageBg(isDark),
      appBar: AppBar(
        backgroundColor: pageBg(isDark),
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
        title: Text(
          'Admin Panel',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('Jobs').snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    glassCard(
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create New Job',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              fieldBox(
                                roleController,
                                'Job Role',
                              ),
                              fieldBox(
                                companyController,
                                'Company',
                              ),
                              fieldBox(
                                locationController,
                                'Location',
                              ),
                              fieldBox(
                                salaryController,
                                'Salary',
                              ),
                              fieldBox(
                                typeController,
                                'Type',
                              ),
                              fieldBox(
                                latitudeController,
                                'Latitude',
                              ),
                              fieldBox(
                                longitudeController,
                                'Longitude',
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          adminField(
                            descriptionController,
                            'Description',
                            maxLines: 5,
                          ),

                          const SizedBox(height: 16),

                          adminField(
                            applyLinkController,
                            'Apply Link',
                          ),

                          const SizedBox(height: 30),

Text(
  'Send Notification',
  style: TextStyle(
    color: isDark ? Colors.white : Colors.black,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 20),

ElevatedButton.icon(
  onPressed: () async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .add({
      'title': '🚀 New Opportunity Added',
      'message':
          'A new fresher job has been added on FresherArena. Check it out now!',
      'type': 'job',
      'createdAt': FieldValue.serverTimestamp(),
    });

    showToast('Notification sent.');
  },
  icon: const Icon(Icons.notifications_active),
  label: const Text('Send Global Notification'),
  style: ElevatedButton.styleFrom(
    backgroundColor:
        isDark ? Colors.white : Colors.black,
    foregroundColor:
        isDark ? Colors.black : Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 18,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
  ),
),


                          const SizedBox(height: 22),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed:
                                  isLoading ? null : addJob,
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.add),
                              label: Text(
                                isLoading
                                    ? 'Adding Job...'
                                    : 'Add Job',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? Colors.white
                                    : Colors.black,
                                foregroundColor: isDark
                                    ? Colors.black
                                    : Colors.white,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      'Live Jobs',
                      style: TextStyle(
                        color:
                            isDark ? Colors.white : Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ...docs.map((doc) {
                      final data =
                          doc.data() as Map<String, dynamic>;

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 18),
                        child: glassCard(
                          isDark: isDark,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: isDark
                                        ? Colors.white
                                        : Colors.black,
                                    child: Text(
                                      '${data['company'] ?? 'J'}'[0]
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          data['role'] ?? '',
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 22,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(
                                            height: 4),

                                        Text(
                                          '${data['company']} • ${data['location']}',
                                          style:
                                              const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  IconButton(
                                    onPressed: () {
                                      updateJob(
                                        id: doc.id,
                                        data: data,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color:
                                          Colors.orangeAccent,
                                    ),
                                  ),

                                  IconButton(
                                    onPressed: () {
                                      deleteJob(doc.id);
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Wrap(
                                spacing: 14,
                                runSpacing: 14,
                                children: [
                                  statChip(
                                    Icons.currency_rupee,
                                    data['salary'] ?? '',
                                  ),
                                  statChip(
                                    Icons.work_outline,
                                    data['type'] ?? '',
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              Text(
                                data['description'] ?? '',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget fieldBox(
    TextEditingController controller,
    String hint,
  ) {
    return SizedBox(
      width: 260,
      child: adminField(controller, hint),
    );
  }

  Widget adminField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.greenAccent,
          ),
        ),
      ),
    );
  }

  Widget statChip(
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.greenAccent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.greenAccent,
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.055)
                : Colors.white.withOpacity(0.84),
            borderRadius: BorderRadius.circular(30),
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