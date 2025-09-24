class CandidateProfile {
  final int id;
  final int userId;
  final String? nui;
  final String? profilePhoto; // URL to the profile photo
  final String? cvFile; // URL to the CV file
  final String? jobTitle;
  final int? experienceYears;
  final String? skills; // Comma separated string
  final List<String>? skillsList; // List of skills for easier handling
  final String? bio;
  final double? expectedSalary;
  final String? location;
  final String? contractType;
  final String? preferredJobType;
  final String? experienceLevel;
  final int? salaryRangeMin;
  final int? salaryRangeMax;
  final String? preferredWorkLocation;
  final bool? remoteWork;
  final String? preferredIndustries;
  final double completionPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  CandidateProfile({
    required this.id,
    required this.userId,
    this.nui,
    this.profilePhoto,
    this.cvFile,
    this.jobTitle,
    this.experienceYears,
    this.skills,
    this.skillsList,
    this.bio,
    this.expectedSalary,
    this.location,
    this.contractType,
    this.preferredJobType,
    this.experienceLevel,
    this.salaryRangeMin,
    this.salaryRangeMax,
    this.preferredWorkLocation,
    this.remoteWork,
    this.preferredIndustries,
    required this.completionPercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CandidateProfile.fromJson(Map<String, dynamic> json) {
    // Parse skills from string to list
    List<String>? skillsList;
    if (json['skills'] != null && json['skills'].toString().isNotEmpty) {
      skillsList = json['skills']
          .toString()
          .split(',')
          .map((s) => s.trim())
          .toList();
    }

    return CandidateProfile(
      id: json['id'] ?? 0,
      userId: json['user'] is Map ? json['user']['id'] ?? 0 : json['user'] ?? 0,
      nui: json['nui'],
      profilePhoto: json['profile_photo'],
      cvFile: json['cv_file'],
      jobTitle: json['job_title'],
      experienceYears: json['experience_years'],
      skills: json['skills'],
      skillsList: skillsList,
      bio: json['bio'],
      expectedSalary: json['expected_salary'] != null
          ? (json['expected_salary'] as num).toDouble()
          : null,
      location: json['location'],
      contractType: json['contract_type'],
      preferredJobType: json['preferred_job_type'],
      experienceLevel: json['experience_level'],
      salaryRangeMin: json['salary_range_min'],
      salaryRangeMax: json['salary_range_max'],
      preferredWorkLocation: json['preferred_work_location'],
      remoteWork: json['remote_work'],
      preferredIndustries: json['preferred_industries'],
      completionPercentage: json['completion_percentage'] != null
          ? (json['completion_percentage'] as num).toDouble()
          : 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'nui': nui,
      'profile_photo': profilePhoto,
      'cv_file': cvFile,
      'job_title': jobTitle,
      'experience_years': experienceYears,
      'skills': skills,
      'skills_list': skillsList,
      'bio': bio,
      'expected_salary': expectedSalary,
      'location': location,
      'contract_type': contractType,
      'preferred_job_type': preferredJobType,
      'experience_level': experienceLevel,
      'salary_range_min': salaryRangeMin,
      'salary_range_max': salaryRangeMax,
      'preferred_work_location': preferredWorkLocation,
      'remote_work': remoteWork,
      'preferred_industries': preferredIndustries,
      'completion_percentage': completionPercentage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper method to get skills as a list
  List<String> get skillsAsList {
    if (skillsList != null) return skillsList!;
    if (skills != null && skills!.isNotEmpty) {
      return skills!.split(',').map((s) => s.trim()).toList();
    }
    return [];
  }
}
