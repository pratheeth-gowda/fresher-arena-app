class Job {
  final String id;
  final String role;
  final String company;
  final String location;
  final String salary;
  final String type;
  final String description;
  final String applyLink;

  final String category;
  final double rating;
  final String deadline;
  final int minSalary;
  final int maxSalary;
  final double latitude;
  final double longitude;
  final List<String> tags;

  const Job({
    required this.id,
    required this.role,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.description,
    required this.applyLink,
    this.category = 'Tech',
    this.rating = 4.5,
    this.deadline = '2026-12-31',
    this.minSalary = 0,
    this.maxSalary = 0,
    this.latitude = 12.9716,
    this.longitude = 77.5946,
    this.tags = const [],
  });

  factory Job.fromFirestore(String id, Map data) {
    return Job(
      id: id,
      role: data['role'] ?? '',
      company: data['company'] ?? '',
      location: data['location'] ?? '',
      salary: data['salary'] ?? '',
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      applyLink: data['applyLink'] ?? '',
      category: data['category'] ?? 'Tech',
      rating: (data['rating'] ?? 4.5).toDouble(),
      deadline: data['deadline'] ?? '2026-12-31',
      minSalary: data['minSalary'] ?? 0,
      maxSalary: data['maxSalary'] ?? 0,
      latitude: (data['latitude'] ?? 12.9716).toDouble(),
      longitude: (data['longitude'] ?? 77.5946).toDouble(),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }
}