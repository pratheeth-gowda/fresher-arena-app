class Job {
  final String id;
  final String role;
  final String company;
  final String location;
  final String salary;
  final String type;
  final String description;
  final String applyLink;

  const Job({
    required this.id,
    required this.role,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.description,
    required this.applyLink,
  });

  factory Job.fromFirestore(String id, Map<String, dynamic> data) {
    return Job(
      id: id,
      role: data['role'] ?? '',
      company: data['company'] ?? '',
      location: data['location'] ?? '',
      salary: data['salary'] ?? '',
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      applyLink: data['applyLink'] ?? '',
    );
  }
}