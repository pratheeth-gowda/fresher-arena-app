import 'package:flutter/material.dart';
import '../models/job.dart';

class JobDetailsPage extends StatelessWidget {
  final Job job;

  const JobDetailsPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020817),
        title: Text(job.company),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Card(
          color: const Color(0xFF0A1628),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.role,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  job.company,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),

                const SizedBox(height: 20),

                Text('📍 Location: ${job.location}',
                    style: const TextStyle(color: Colors.grey, fontSize: 16)),

                const SizedBox(height: 10),

                Text('💼 Type: ${job.type}',
                    style: const TextStyle(color: Colors.grey, fontSize: 16)),

                const SizedBox(height: 10),

                Text('💰 Salary: ${job.salary}',
                    style: const TextStyle(color: Colors.grey, fontSize: 16)),

                const SizedBox(height: 25),

                const Text(
                  'Job Description',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  job.description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.all(14),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Applied to ${job.company}')),
                      );
                    },
                    child: const Text(
                      'Apply Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}