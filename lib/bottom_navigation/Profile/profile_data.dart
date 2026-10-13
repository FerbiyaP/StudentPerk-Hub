import '../../services/auth_service.dart';

class ProfileData {
  final String name;
  final String college;
  final String email;
  final String department;
  final String year;
  final String graduationYear;
  final String location;
  final bool studentVerified;
  final bool emailVerified;
  final bool notificationsEnabled;
  final String photoUrl;

  ProfileData({
    required this.name,
    required this.college,
    required this.email,
    required this.department,
    required this.year,
    required this.graduationYear,
    required this.location,
    required this.studentVerified,
    required this.emailVerified,
    required this.notificationsEnabled,
    required this.photoUrl,
  });

  factory ProfileData.fromAuth(AuthService auth) {
    return ProfileData(
      name: auth.name.isEmpty ? 'Student' : auth.name,
      college: auth.college,
      email: auth.email,
      department: auth.department,
      year: auth.year,
      graduationYear: auth.graduationYear,
      location: auth.location,
      studentVerified: auth.studentVerified,
      emailVerified: auth.emailVerified,
      notificationsEnabled: auth.notificationsEnabled,
      photoUrl: auth.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'college': college,
      'email': email,
      'department': department,
      'year': year,
      'graduationYear': graduationYear,
      'location': location,
      'studentVerified': studentVerified,
      'emailVerified': emailVerified,
      'notificationsEnabled': notificationsEnabled,
      'photoUrl': photoUrl,
    };
  }
}
