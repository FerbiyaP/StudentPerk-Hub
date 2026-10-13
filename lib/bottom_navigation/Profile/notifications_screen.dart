import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  bool _perkUpdates = true;
  bool _expiryReminders = true;
  bool _newOffers = true;
  bool _applicationUpdates = true;
  bool _emailNotifications = false;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _perkUpdates = prefs.getBool('notif_perk_updates') ?? true;
      _expiryReminders = prefs.getBool('notif_expiry_reminders') ?? true;
      _newOffers = prefs.getBool('notif_new_offers') ?? true;
      _applicationUpdates = prefs.getBool('notif_application_updates') ?? true;
      _emailNotifications = prefs.getBool('notif_email_notifications') ?? false;
      _loading = false;
    });
  }

  Future<void> _updateSetting(
      String field,
      bool value,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notif_$field', value);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update notification settings.',
          ),
        ),
      );
    }
  }

  void _changeSetting(
      String field,
      bool value,
      Function(bool) updateLocal,
      ) {
    setState(() {
      updateLocal(value);
    });

    _updateSetting(field, value);
  }

  @override
  Widget build(BuildContext context) {
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
          'Notifications',
          style: TextStyle(
            color: Color(0xFF172554),
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: _loading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5146D8),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 28),

            const Text(
              'PERK UPDATES',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 10),

            _buildNotificationCard([
              _buildSwitchTile(
                icon: Icons.local_offer_outlined,
                title: 'New student offers',
                subtitle:
                'Get notified when new perks are available.',
                value: _newOffers,
                onChanged: (value) {
                  _changeSetting(
                    'newOffers',
                    value,
                        (v) => _newOffers = v,
                  );
                },
              ),

              _buildDivider(),

              _buildSwitchTile(
                icon: Icons.card_giftcard_outlined,
                title: 'Perk updates',
                subtitle:
                'Updates about your saved and active perks.',
                value: _perkUpdates,
                onChanged: (value) {
                  _changeSetting(
                    'perkUpdates',
                    value,
                        (v) => _perkUpdates = v,
                  );
                },
              ),

              _buildDivider(),

              _buildSwitchTile(
                icon: Icons.access_time_rounded,
                title: 'Expiry reminders',
                subtitle:
                'Never miss an expiring student benefit.',
                value: _expiryReminders,
                onChanged: (value) {
                  _changeSetting(
                    'expiryReminders',
                    value,
                        (v) => _expiryReminders = v,
                  );
                },
              ),
            ]),

            const SizedBox(height: 28),

            const Text(
              'ACCOUNT',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 10),

            _buildNotificationCard([
              _buildSwitchTile(
                icon: Icons.assignment_outlined,
                title: 'Application updates',
                subtitle:
                'Get updates about your benefit applications.',
                value: _applicationUpdates,
                onChanged: (value) {
                  _changeSetting(
                    'applicationUpdates',
                    value,
                        (v) => _applicationUpdates = v,
                  );
                },
              ),

              _buildDivider(),

              _buildSwitchTile(
                icon: Icons.email_outlined,
                title: 'Email notifications',
                subtitle:
                'Receive important updates by email.',
                value: _emailNotifications,
                onChanged: (value) {
                  _changeSetting(
                    'emailNotifications',
                    value,
                        (v) => _emailNotifications = v,
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEEF0FF),
            Color(0xFFF5F3FF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Color(0xFFE1E4FF),
            child: Icon(
              Icons.notifications_active_outlined,
              color: Color(0xFF5146D8),
              size: 28,
            ),
          ),

          SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay in the loop',
                  style: TextStyle(
                    color: Color(0xFF172554),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Choose what you want to hear about.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
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

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
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
              color: const Color(0xFF243B6B),
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
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: value,
            activeThumbColor: const Color(0xFF5146D8),
            onChanged: onChanged,
          ),
        ],
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
}