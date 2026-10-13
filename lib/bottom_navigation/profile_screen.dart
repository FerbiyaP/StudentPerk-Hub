import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile/notifications_screen.dart';
import 'profile/help_support_screen.dart';
import 'profile/privacy_security_screen.dart';

import '../screens/student_verification_screen.dart';
import '../screens/email_verification_screen.dart';
import '../screens/auth/login_screen.dart';
import '../services/auth_service.dart';

const Color primaryColor = Color(0xFF5146D8);
const Color darkColor = Color(0xFF172554);
const Color secondaryTextColor = Color(0xFF64748B);
const Color backgroundColor = Color(0xFFF8F9FC);

class StudentProfile {
  final String name;
  final String email;
  final String college;
  final String department;
  final String year;
  final String graduationYear;
  final String location;
  final bool studentVerified;
  final bool emailVerified;
  final bool notificationsEnabled;
  final String photoUrl;

  const StudentProfile({
    required this.name,
    required this.email,
    required this.college,
    required this.department,
    required this.year,
    required this.graduationYear,
    required this.location,
    required this.studentVerified,
    required this.emailVerified,
    required this.notificationsEnabled,
    required this.photoUrl,
  });

  factory StudentProfile.fromMap(
      Map<String, dynamic> data,
      User user,
      ) {
    final metadata = user.userMetadata ?? {};

    return StudentProfile(
      name: _value(
        data['full_name'],
        _value(
          metadata['full_name'],
          _value(metadata['name'], 'Student'),
        ),
      ),
      email: user.email ?? _value(data['email'], ''),
      college: _value(data['college'], ''),
      department: _value(data['department'], ''),
      year: _value(data['study_year'], ''),
      graduationYear: _value(data['graduation_year'], ''),
      location: _value(data['location'], ''),
      studentVerified: data['student_verified'] == true,
      emailVerified: user.emailConfirmedAt != null,
      notificationsEnabled: data['notifications_enabled'] != false,
      photoUrl: _value(data['photo_url'], ''),
    );
  }

  static String _value(dynamic value, String fallback) {
    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }
    return value.toString();
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool _isUploadingImage = false;
  StudentProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      final authService = AuthService.instance;

      if (user == null && !authService.isLoggedIn) {
        _profile = StudentProfile(
          name: 'Guest User',
          email: 'Sign in to access student perks',
          college: 'College not added',
          department: 'Department not added',
          year: 'Year not added',
          graduationYear: 'Not added',
          location: 'Chennai, Tamil Nadu',
          studentVerified: false,
          emailVerified: false,
          notificationsEnabled: true,
          photoUrl: '',
        );
        return;
      }

      if (user != null) {
        try {
          final result = await _supabase
              .from('student_profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();

          if (result != null) {
            _profile = StudentProfile.fromMap(result, user);
            return;
          }
        } catch (_) {}
      }

      _profile = StudentProfile(
        name: authService.name.isNotEmpty ? authService.name : 'Student',
        email: authService.email.isNotEmpty ? authService.email : (user?.email ?? ''),
        college: authService.college != 'College not added' ? authService.college : '',
        department: authService.department != 'Department not added' ? authService.department : '',
        year: authService.year != 'Year not added' ? authService.year : '',
        graduationYear: authService.graduationYear != 'Not added' ? authService.graduationYear : '',
        location: authService.location,
        studentVerified: authService.studentVerified,
        emailVerified: authService.emailVerified || (user?.emailConfirmedAt != null),
        notificationsEnabled: authService.notificationsEnabled,
        photoUrl: authService.photoUrl,
      );
    } catch (e) {
      final authService = AuthService.instance;
      _profile = StudentProfile(
        name: authService.name.isNotEmpty ? authService.name : 'Student',
        email: authService.email,
        college: authService.college != 'College not added' ? authService.college : '',
        department: authService.department != 'Department not added' ? authService.department : '',
        year: authService.year != 'Year not added' ? authService.year : '',
        graduationYear: authService.graduationYear != 'Not added' ? authService.graduationYear : '',
        location: authService.location,
        studentVerified: authService.studentVerified,
        emailVerified: authService.emailVerified,
        notificationsEnabled: authService.notificationsEnabled,
        photoUrl: authService.photoUrl,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    if (_profile == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Profile data not available.',
                style: TextStyle(
                  fontSize: 16,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: _loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 18),
                _buildProfileHeader(),
                const SizedBox(height: 28),
                _buildSectionTitle('My Profile'),
                const SizedBox(height: 12),
                _buildMyProfileSection(),
                const SizedBox(height: 28),
                _buildSectionTitle('Account & Support'),
                const SizedBox(height: 12),
                _buildAccountSection(),
                const SizedBox(height: 24),
                _buildFooter(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF0FF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Color(0xFF4D46D9),
            size: 25,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'StudentPerk ',
                  style: TextStyle(
                    color: darkColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: 'Hub',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildTopIcon(
          Icons.notifications_none_rounded,
          _openNotificationSettings,
          showDot: true,
        ),
        const SizedBox(width: 8),
        _buildTopIcon(Icons.settings_outlined, _openSettings),
      ],
    );
  }

  Widget _buildTopIcon(
      IconData icon,
      VoidCallback onTap, {
        bool showDot = false,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          children: [
            Center(
              child: Icon(icon, color: darkColor, size: 26),
            ),
            if (showDot)
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE63946),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final profile = _profile!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3FA),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _buildProfileImage(),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  profile.department.isEmpty
                      ? 'Department not added'
                      : profile.department,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 9),
                _buildDetailRow(
                  Icons.account_balance_outlined,
                  profile.college.isEmpty
                      ? 'College not added'
                      : profile.college,
                ),
                const SizedBox(height: 7),
                _buildDetailRow(
                  Icons.location_on_outlined,
                  profile.location.isEmpty
                      ? 'Location not added'
                      : profile.location,
                ),
                const SizedBox(height: 12),
                _buildVerifiedBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: secondaryTextColor, size: 17),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    final photo = _profile!.photoUrl;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            color: const Color(0xFFE5E7EB),
          ),
          child: ClipOval(
            child: _isUploadingImage
                ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 2.5,
              ),
            )
                : _buildPhoto(photo),
          ),
        ),
        Positioned(
          right: -3,
          bottom: -2,
          child: GestureDetector(
            onTap: _isUploadingImage ? null : _pickAndUploadProfileImage,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 16,
                color: darkColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoto(String photo) {
    if (photo.startsWith('http://') || photo.startsWith('https://')) {
      return Image.network(
        photo,
        fit: BoxFit.cover,
        errorBuilder: (_, __, _) => _defaultPhoto(),
      );
    }

    if (photo.isNotEmpty) {
      return Image.file(
        File(photo),
        fit: BoxFit.cover,
        errorBuilder: (_, __, _) => _defaultPhoto(),
      );
    }

    return _defaultPhoto();
  }

  Widget _defaultPhoto() {
    return Image.asset(
      'assets/images/profile.jpg',
      fit: BoxFit.cover,
      errorBuilder: (_, __, _) => const Icon(
        Icons.person_rounded,
        size: 55,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  Future<void> _pickAndUploadProfileImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile == null || !mounted) return;

    setState(() => _isUploadingImage = true);

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Please sign in first.');
      }

      // Local-only for now. This does not upload the image to Supabase.
      final oldProfile = _profile!;

      await _supabase.from('student_profiles').upsert({
        'id': user.id,
        'full_name': oldProfile.name,
        'email': user.email ?? oldProfile.email,
        'college': oldProfile.college,
        'department': oldProfile.department,
        'study_year': oldProfile.year,
        'graduation_year': int.tryParse(oldProfile.graduationYear),
        'location': oldProfile.location,
        'student_verified': oldProfile.studentVerified,
        'photo_url': '',
      }, onConflict: 'id');

      setState(() {
        _profile = StudentProfile(
          name: oldProfile.name,
          email: oldProfile.email,
          college: oldProfile.college,
          department: oldProfile.department,
          year: oldProfile.year,
          graduationYear: oldProfile.graduationYear,
          location: oldProfile.location,
          studentVerified: oldProfile.studentVerified,
          emailVerified: oldProfile.emailVerified,
          notificationsEnabled: oldProfile.notificationsEnabled,
          photoUrl: pickedFile.path,
        );
      });

      _showMessage(
        'Picture selected on this device. Cloud photo storage is not configured yet.',
      );
    } catch (e) {
      _showMessage('Failed to update picture: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Widget _buildVerifiedBadge() {
    final verified = _profile!.studentVerified || _profile!.emailVerified;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: verified
            ? const Color(0xFFE6F8EF)
            : const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: verified
              ? const Color(0xFFBCEBD2)
              : const Color(0xFFF6D7A7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified
                ? Icons.check_circle_rounded
                : Icons.info_outline_rounded,
            color: verified
                ? const Color(0xFF159A5B)
                : const Color(0xFFD88900),
            size: 17,
          ),
          const SizedBox(width: 6),
          Text(
            verified ? 'Verified Student' : 'Verification Pending',
            style: TextStyle(
              color: verified
                  ? const Color(0xFF16804A)
                  : const Color(0xFFD88900),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: darkColor,
        fontSize: 21,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildMyProfileSection() {
    return _buildMenuContainer([
      _buildMenuItem(
        icon: Icons.person_outline_rounded,
        title: 'Personal Information',
        subtitle: 'Name, email, college, department, year',
        onTap: _showPersonalInformation,
      ),
      _buildDivider(),
      _buildMenuItem(
        icon: Icons.verified_user_outlined,
        title: 'Student Verification',
        subtitle: 'College ID & student details',
        verified: _profile!.studentVerified,
        onTap: _showStudentVerification,
      ),
      _buildDivider(),
      _buildMenuItem(
        icon: Icons.mail_outline_rounded,
        title: 'Email Verification',
        subtitle: 'Verify your email for complete access',
        verified: _profile!.emailVerified,
        onTap: _handleEmailVerification,
      ),
    ]);
  }

  Widget _buildAccountSection() {
    final bool isLoggedIn = AuthService.instance.isLoggedIn || _supabase.auth.currentUser != null;

    return _buildMenuContainer([
      _buildMenuItem(
        icon: Icons.notifications_none_rounded,
        title: 'Notifications',
        subtitle: _profile!.notificationsEnabled
            ? 'Notifications are enabled'
            : 'Notifications are disabled',
        onTap: _openNotificationSettings,
      ),
      _buildDivider(),
      _buildMenuItem(
        icon: Icons.help_outline_rounded,
        title: 'Help & Support',
        subtitle: 'FAQs, contact us',
        onTap: _openHelpSupport,
      ),
      _buildDivider(),
      _buildMenuItem(
        icon: Icons.shield_outlined,
        title: 'Privacy & Security',
        subtitle: 'Keep your account safe',
        onTap: _openPrivacySecurity,
      ),
      _buildDivider(),
      if (isLoggedIn)
        _buildMenuItem(
          icon: Icons.logout_rounded,
          title: 'Log Out',
          subtitle: 'Sign out from your account',
          onTap: _showLogoutDialog,
        )
      else
        _buildMenuItem(
          icon: Icons.login_rounded,
          title: 'Log In / Register',
          subtitle: 'Sign in to access all student perks',
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
            );
            await _loadProfile();
          },
        ),
    ]);
  }

  Widget _buildMenuContainer(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 70),
      child: Divider(height: 1, color: Color(0xFFE8ECF2)),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool verified = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F4FA),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF243B6B), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: darkColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (verified)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8EF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Color(0xFF159A5B),
                    ),
                    SizedBox(width: 3),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: Color(0xFF159A5B),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 7),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 23,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF1F4FF), Color(0xFFF7F5FF)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.eco_outlined, color: Color(0xFF31945C), size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student today. Leader tomorrow.',
                  style: TextStyle(
                    color: Color(0xFF243B6B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Access more. Achieve more.',
                  style: TextStyle(color: secondaryTextColor, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(Icons.school_outlined, color: Color(0xFF9EA8E9), size: 30),
        ],
      ),
    );
  }

  Future<void> _showPersonalInformation() async {
    final profile = _profile!;

    final nameController = TextEditingController(text: profile.name);
    final collegeController = TextEditingController(text: profile.college);
    final departmentController =
    TextEditingController(text: profile.department);
    final yearController = TextEditingController(text: profile.year);
    final graduationController =
    TextEditingController(text: profile.graduationYear);
    final locationController = TextEditingController(text: profile.location);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Personal Information',
            style: TextStyle(
              color: darkColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildEditField(
                  controller: nameController,
                  label: 'Name',
                  icon: Icons.person_outline,
                ),
                _buildEditField(
                  controller: collegeController,
                  label: 'College',
                  icon: Icons.account_balance_outlined,
                ),
                _buildEditField(
                  controller: departmentController,
                  label: 'Department',
                  icon: Icons.school_outlined,
                ),
                _buildEditField(
                  controller: yearController,
                  label: 'Year',
                  icon: Icons.calendar_today_outlined,
                ),
                _buildEditField(
                  controller: graduationController,
                  label: 'Graduation Year',
                  icon: Icons.event_available_outlined,
                  keyboardType: TextInputType.number,
                ),
                _buildEditField(
                  controller: locationController,
                  label: 'Location',
                  icon: Icons.location_on_outlined,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: secondaryTextColor),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await _updateProfile(
                  name: nameController.text.trim(),
                  college: collegeController.text.trim(),
                  department: departmentController.text.trim(),
                  year: yearController.text.trim(),
                  graduationYear: graduationController.text.trim(),
                  location: locationController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    collegeController.dispose();
    departmentController.dispose();
    yearController.dispose();
    graduationController.dispose();
    locationController.dispose();
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfile({
    required String name,
    required String college,
    required String department,
    required String year,
    required String graduationYear,
    required String location,
  }) async {
    try {
      final user = _supabase.auth.currentUser;

      if (user != null) {
        try {
          await _supabase.from('student_profiles').upsert({
            'id': user.id,
            'full_name': name,
            'email': user.email ?? '',
            'college': college,
            'department': department,
            'study_year': year,
            'graduation_year': int.tryParse(graduationYear),
            'location': location,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }, onConflict: 'id');
        } catch (_) {}
      }

      await AuthService.instance.updateProfile(
        name: name,
        college: college,
        department: department,
        year: year,
        graduationYear: graduationYear,
        location: location,
      );

      await _loadProfile();
      _showMessage('Profile updated successfully.');
    } catch (e) {
      _showMessage('Failed to update profile: $e', isError: true);
    }
  }

  void _showStudentVerification() {
    final profile = _profile!;
    final verified = profile.studentVerified;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              Icon(
                verified
                    ? Icons.verified_rounded
                    : Icons.info_outline_rounded,
                color: verified
                    ? const Color(0xFF159A5B)
                    : const Color(0xFFD88900),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Student Verification',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: darkColor,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                verified
                    ? 'Your student profile has been verified.'
                    : 'Your student profile has not been verified yet.',
                style: const TextStyle(
                  color: secondaryTextColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              _buildInfoRow('College', profile.college),
              _buildInfoRow('Department', profile.department),
              _buildInfoRow('Year', profile.year),
              _buildInfoRow('Graduation', profile.graduationYear),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(color: secondaryTextColor),
              ),
            ),
            if (!verified)
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentVerificationScreen(),
                    ),
                  );

                  await _loadProfile();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text('Verify Now'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: secondaryTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not added' : value,
              style: const TextStyle(
                color: darkColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEmailVerification() async {
    final user = _supabase.auth.currentUser;
    final email = user?.email ?? AuthService.instance.email;

    if (email.isEmpty) {
      _showMessage('Please sign in first.', isError: true);
      return;
    }

    if (AuthService.instance.emailVerified || user?.emailConfirmedAt != null) {
      _showMessage('Your email is already verified.');
      await _loadProfile();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmailVerificationScreen(
          email: email,
        ),
      ),
    );

    await _loadProfile();
  }

  void _openNotificationSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );
  }

  void _openSettings() {
    _openNotificationSettings();
  }

  void _openHelpSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HelpSupportScreen(),
      ),
    );
  }

  void _openPrivacySecurity() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrivacySecurityScreen(),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Log Out?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: darkColor,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of StudentPerk Hub?',
            style: TextStyle(color: secondaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: secondaryTextColor),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      await _supabase.auth.signOut();

      if (!mounted) return;

      setState(() => _profile = null);
      _showMessage('Logged out successfully.');
    } catch (e) {
      _showMessage('Unable to log out: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? const Color(0xFFD64545)
              : darkColor,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}