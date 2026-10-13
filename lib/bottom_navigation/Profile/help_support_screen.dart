import 'package:flutter/material.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() =>
      _HelpSupportScreenState();
}

class _HelpSupportScreenState
    extends State<HelpSupportScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I verify my student account?',
      'answer':
      'Go to Profile → Student Verification and provide your college and student details. Follow the verification instructions shown there.',
    },
    {
      'question': 'How do I claim a student perk?',
      'answer':
      'Open an offer from the Offers screen and tap the Claim or Get Benefit button. Follow the provider instructions to complete the process.',
    },
    {
      'question': 'Where can I find my saved perks?',
      'answer':
      'Your saved perks are available from the Vault section of StudentPerk Hub.',
    },
    {
      'question': 'Why is my student verification pending?',
      'answer':
      'Verification may take some time depending on the information provided. Make sure your college details and student email are correct.',
    },
    {
      'question': 'How do I change my profile information?',
      'answer':
      'Go to Profile → Personal Information. Edit the required information and tap Save.',
    },
    {
      'question': 'How do I report an incorrect perk?',
      'answer':
      'Open the perk and use the Report option. You can also contact our support team.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Help & Support',
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
            _buildSupportHeader(),

            const SizedBox(height: 22),

            _buildSearchBar(),

            const SizedBox(height: 28),

            const Text(
              'QUICK HELP',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 10),

            _buildQuickHelp(),

            const SizedBox(height: 28),

            const Text(
              'FREQUENTLY ASKED QUESTIONS',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 10),

            _buildFaqSection(),

            const SizedBox(height: 28),

            _buildContactSupport(),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF202F68),
            Color(0xFF394B91),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.support_agent_rounded,
            color: Colors.white,
            size: 38,
          ),

          SizedBox(height: 14),

          Text(
            'How can we help?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 6),

          Text(
            'Find answers or get in touch with our support team.',
            style: TextStyle(
              color: Color(0xFFDDE3FF),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search for help...',
          hintStyle: TextStyle(
            color: Color(0xFF94A3B8),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Color(0xFF64748B),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickHelp() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickHelpCard(
            icon: Icons.school_outlined,
            title: 'Student\nVerification',
            onTap: () {
              _showMessage(
                'Student Verification',
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildQuickHelpCard(
            icon: Icons.local_offer_outlined,
            title: 'Perks &\nOffers',
            onTap: () {
              _showMessage('Perks & Offers');
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildQuickHelpCard(
            icon: Icons.account_circle_outlined,
            title: 'Account\nHelp',
            onTap: () {
              _showMessage('Account Help');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickHelpCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF5146D8),
              size: 27,
            ),

            const SizedBox(height: 10),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF172554),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: List.generate(
          _faqs.length,
              (index) {
            final faq = _faqs[index];

            return Column(
              children: [
                ExpansionTile(
                  tilePadding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  childrenPadding:
                  const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    16,
                  ),
                  iconColor:
                  const Color(0xFF5146D8),
                  collapsedIconColor:
                  const Color(0xFF64748B),
                  title: Text(
                    faq['question']!,
                    style: const TextStyle(
                      color: Color(0xFF172554),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  children: [
                    Text(
                      faq['answer']!,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),

                if (index != _faqs.length - 1)
                  const Divider(
                    height: 1,
                    color: Color(0xFFE8ECF2),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContactSupport() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFE0E2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mail_outline_rounded,
              color: Color(0xFF5146D8),
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Still need help?',
                  style: TextStyle(
                    color: Color(0xFF172554),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Contact our support team.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              _showMessage(
                'Opening support email...',
              );
            },
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFF5146D8),
            ),
          ),
        ],
      ),
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