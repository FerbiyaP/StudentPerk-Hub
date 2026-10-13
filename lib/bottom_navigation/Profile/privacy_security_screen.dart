import 'package:flutter/material.dart';
import 'package:stuentperk_hub/services/auth_service.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() =>
      _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState
    extends State<PrivacySecurityScreen> {

  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FC),
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF172554),
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Privacy & Security',
          style: TextStyle(
            color: Color(0xFF172554),
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildSecurityHeader(),

            const SizedBox(height: 28),

            const Text(
              'ACCOUNT SECURITY',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 10),

            _buildSecurityCard([
              _buildSecurityItem(
                icon: Icons.email_outlined,
                title: 'Email Address',
                subtitle:
                user?.email ?? 'No email available',
                trailing: _buildVerifiedBadge(
                  user?.emailVerified ?? false,
                ),
                onTap: () {
                  _showEmailInfo();
                },
              ),

              _buildDivider(),

              _buildSecurityItem(
                icon: Icons.lock_outline_rounded,
                title: 'Password',
                subtitle: 'Change your account password',
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
                onTap: _changePassword,
              ),

              _buildDivider(),

              _buildSecurityItem(
                icon: Icons.phone_android_outlined,
                title: 'Biometric Lock',
                subtitle:
                'Use fingerprint or face unlock',
                trailing: Switch(
                  value: _biometricEnabled,
                  activeThumbColor:
                  const Color(0xFF5146D8),
                  onChanged: (value) {
                    setState(() {
                      _biometricEnabled = value;
                    });
                  },
                ),
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 28),

            const Text(
              'YOUR DATA',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 10),

            _buildSecurityCard([
              _buildSecurityItem(
                icon: Icons.download_outlined,
                title: 'Download My Data',
                subtitle:
                'Request a copy of your account data',
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
                onTap: _downloadData,
              ),

              _buildDivider(),

              _buildSecurityItem(
                icon: Icons.description_outlined,
                title: 'Privacy Policy',
                subtitle:
                'Learn how we handle your information',
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
                onTap: _showPrivacyPolicy,
              ),

              _buildDivider(),

              _buildSecurityItem(
                icon: Icons.gavel_outlined,
                title: 'Terms of Service',
                subtitle:
                'Review our terms and conditions',
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
                onTap: _showTerms,
              ),
            ]),

            const SizedBox(height: 28),

            const Text(
              'DANGER ZONE',
              style: TextStyle(
                color: Color(0xFFD64545),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 10),

            _buildDeleteAccountCard(),

            const SizedBox(height: 22),

            const Center(
              child: Text(
                'StudentPerk Hub • Your data, your control.',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEAF8F0),
            Color(0xFFF2FAF6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD5EFDF),
        ),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Color(0xFFD7F1E2),
            child: Icon(
              Icons.shield_outlined,
              color: Color(0xFF159A5B),
              size: 29,
            ),
          ),

          SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Your account is protected',
                  style: TextStyle(
                    color: Color(0xFF17633E),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Manage your security and privacy settings.',
                  style: TextStyle(
                    color: Color(0xFF5E7C6C),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(
      List<Widget> children,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F4FA),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Color(0xFF243B6B),
                size: 21,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF172554),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildVerifiedBadge(bool verified) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: verified
            ? const Color(0xFFE8F8EF)
            : const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        verified ? 'Verified' : 'Not verified',
        style: TextStyle(
          color: verified
              ? const Color(0xFF159A5B)
              : const Color(0xFFD88900),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDeleteAccountCard() {
    return GestureDetector(
      onTap: _deleteAccount,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF3D2D2),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFD64545),
              size: 23,
            ),

            SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Color(0xFFD64545),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Permanently delete your StudentPerk Hub account.',
                    style: TextStyle(
                      color: Color(0xFF9B6666),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFD64545),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 73),
      child: Divider(
        height: 1,
        color: Color(0xFFE8ECF2),
      ),
    );
  }

  void _showEmailInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Email Security'),
          content: const Text(
            'Your email is used to secure your StudentPerk Hub account and for important account notifications.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword() async {
    final email = AuthService.instance.currentUser?.email;

    if (email == null) return;

    try {
      await AuthService.instance.sendPasswordReset(
        email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to send password reset email.',
          ),
        ),
      );
    }
  }

  void _downloadData() {
    _showMessage(
      'Your data request has been submitted.',
    );
  }

  void _showPrivacyPolicy() {
    _showDocument(
      'Privacy Policy',
      'StudentPerk Hub respects your privacy. Your account and student information is used to provide personalized student benefits and account functionality.',
    );
  }

  void _showTerms() {
    _showDocument(
      'Terms of Service',
      'By using StudentPerk Hub, you agree to use the platform responsibly and provide accurate student information when requesting student benefits.',
    );
  }

  void _showDocument(
      String title,
      String content,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              20,
              22,
              30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF172554),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  content,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF5146D8),
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Account?',
            style: TextStyle(
              color: Color(0xFF172554),
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'This action cannot be undone. Your account will be permanently deleted.',
            style: TextStyle(
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                final navigator = Navigator.of(context);

                try {
                  await AuthService.instance.currentUser?.delete();

                  if (!mounted) return;

                  navigator.pop();
                } catch (e) {
                  _showMessage(
                    'Please sign in again before deleting your account.',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFFD64545),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}