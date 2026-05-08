import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/jobs_data.dart';
import '../models/job.dart';
import 'job_details_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  String search = '';
  List<Job> savedJobs = [];

  @override
  void initState() {
    super.initState();
    loadSavedJobs();
  }

  Future<void> saveJobsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = savedJobs.map((job) => job.id.toString()).toList();
    await prefs.setStringList('saved_jobs', savedIds);
  }

  Future<void> loadSavedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedIds = prefs.getStringList('saved_jobs');

    if (storedIds != null) {
      final jobIds = storedIds.map((id) => int.parse(id)).toList();

      setState(() {
        savedJobs = jobs.where((job) => jobIds.contains(job.id)).toList();
      });
    }
  }

  void toggleSave(Job job) {
    setState(() {
      if (savedJobs.any((savedJob) => savedJob.id == job.id)) {
        savedJobs.removeWhere((savedJob) => savedJob.id == job.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${job.company} removed from saved jobs')),
        );
      } else {
        savedJobs.add(job);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${job.company} saved')),
        );
      }
    });

    saveJobsToStorage();
  }

  @override
  Widget build(BuildContext context) {
    final filteredJobs = jobs.where((job) {
      return job.role.toLowerCase().contains(search.toLowerCase()) ||
          job.company.toLowerCase().contains(search.toLowerCase()) ||
          job.location.toLowerCase().contains(search.toLowerCase());
    }).toList();

    return Scaffold(
      body: currentIndex == 0
          ? buildHome(filteredJobs)
          : currentIndex == 1
              ? buildSavedPage()
              : const ProfilePage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: const Color(0xFF0A1628),
        selectedItemColor: const Color(0xFF38BDF8),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget buildHome(List<Job> filteredJobs) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020817),
        title: const Text(
          'FresherArena',
          style: TextStyle(
            color: Color(0xFF38BDF8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: buildJobList(filteredJobs, showSearch: true),
    );
  }

  Widget buildSavedPage() {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020817),
        title: const Text(
          'Saved Jobs',
          style: TextStyle(
            color: Color(0xFF38BDF8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: savedJobs.isEmpty
          ? const Center(
              child: Text(
                'No saved jobs yet',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            )
          : buildJobList(savedJobs, showSearch: false),
    );
  }

  Widget buildJobList(List<Job> jobList, {required bool showSearch}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (showSearch) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Find your first job easily',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search company, role or city...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF38BDF8)),
                filled: true,
                fillColor: const Color(0xFF0A1628),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
            ),
            const SizedBox(height: 16),
          ],

          Expanded(
            child: ListView.builder(
              itemCount: jobList.length,
              itemBuilder: (context, index) {
                final job = jobList[index];
                final isSaved =
                    savedJobs.any((savedJob) => savedJob.id == job.id);

                return Card(
                  color: const Color(0xFF0A1628),
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      job.role,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${job.company}\n${job.location} • ${job.type}\nSalary: ${job.salary}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? Colors.redAccent : Colors.grey,
                      ),
                      onPressed: () => toggleSave(job),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobDetailsPage(job: job),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}