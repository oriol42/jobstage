class User {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String userType;
  final bool isVerified;
  final DateTime dateJoined;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    required this.userType,
    required this.isVerified,
    required this.dateJoined,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      userType: json['user_type'],
      isVerified: json['is_verified'],
      dateJoined: DateTime.parse(json['date_joined']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'user_type': userType,
      'is_verified': isVerified,
      'date_joined': dateJoined.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, userType: $userType)';
  }
}
