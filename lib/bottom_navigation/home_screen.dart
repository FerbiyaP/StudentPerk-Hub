import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'myperks_screen.dart';
import 'Explore/explore_screen_data.dart';
import 'My_Perks/perks_tracker.dart';
import '../categories/student_benefits.dart';
import '../categories/student_plans.dart';
import '../categories/free_certifications.dart';
import '../categories/discounts.dart';
import 'package:url_launcher/url_launcher.dart';

// ------------------------------------------------
// FEATURED BANNER MODEL
// ------------------------------------------------
class _FeaturedBanner {
  final String title;
  final String subtitle;
  final String domain;
  final String url;
  final IconData fallbackIcon;

  const _FeaturedBanner({
    required this.title,
    required this.subtitle,
    required this.domain,
    required this.url,
    required this.fallbackIcon,
  });
}

const List<_FeaturedBanner> _featuredBanners = [
  _FeaturedBanner(
    title: 'GitHub Student Developer Pack',
    subtitle: 'Developer tools, Copilot, Codespaces',
    domain: 'github.com',
    url: 'https://education.github.com/pack',
    fallbackIcon: Icons.code_rounded,
  ),
  _FeaturedBanner(
    title: 'Azure for Students',
    subtitle: '\$100 Credit + 25+ Free Services',
    domain: 'azure.microsoft.com',
    url: 'https://azure.microsoft.com/free/students',
    fallbackIcon: Icons.cloud_outlined,
  ),
  _FeaturedBanner(
    title: 'JetBrains Student Pack',
    subtitle: 'All Products Free (IntelliJ, PyCharm, etc.)',
    domain: 'jetbrains.com',
    url: 'https://www.jetbrains.com/student/',
    fallbackIcon: Icons.developer_mode_rounded,
  ),
];

// ------------------------------------------------
// MATCHED PERK MODEL
// ------------------------------------------------
class MatchedPerk {
  final String category;
  final String vendor;
  final String title;
  final String description;
  final String badgeText;
  final Color vendorColor;
  final IconData icon;
  final String? logoUrl;
  final Color iconBg;

  const MatchedPerk({
    required this.category,
    required this.vendor,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.vendorColor,
    required this.icon,
    required this.logoUrl,
    required this.iconBg,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _selectedCategoryIndex = 0;
  int _selectedTab = 0;
  int _heroPage = 0;
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // CATEGORIES
  final List<String> _categories = const [
    'All',
    'Student Benefits',
    'Student Plans',
    'Free Certifications',
    'Student Discounts',
  ];

  final List<MatchedPerk> _allMatchedPerks = const [
    // ------------------------------------------------
    // 1. STUDENT BENEFITS
    // ------------------------------------------------
    MatchedPerk(
      category: 'Student Benefits',
      vendor: 'GitHub',
      title: 'GitHub Student Developer Pack',
      description:
          'Developer tools, Copilot, Codespaces + partner offers from DigitalOcean, Namecheap, and Azure.',
      badgeText: '100% Free Pack',
      vendorColor: Color(0xFF4F46E5),
      icon: Icons.code_rounded,
      logoUrl: 'assets/logos/github.svg',
      iconBg: Color(0xFFE9E9FF),
    ),
    MatchedPerk(
      category: 'Student Benefits',
      vendor: 'Microsoft',
      title: 'Azure for Students',
      description:
          '\$100 Azure credit for 12 months + 25+ free services, no credit card required.',
      badgeText: '\$100 Free Credit',
      vendorColor: Color(0xFF0284C7),
      icon: Icons.cloud_outlined,

      logoUrl: 'assets/logos/microsoft.svg',
      iconBg: Color(0xFFE0F2FE),
    ),
    MatchedPerk(
      category: 'Student Benefits',
      vendor: 'JetBrains',
      title: 'JetBrains Student Pack',
      description:
          'Free 1-year renewable access to IntelliJ IDEA, PyCharm, WebStorm, Rider, and DataGrip.',
      badgeText: 'Free 1-Yr Access',
      vendorColor: Color(0xFF0E7490),
      icon: Icons.terminal_rounded,
      logoUrl: 'assets/logos/jetbrains.svg',
      iconBg: Color(0xFFE6FBFD),
    ),
    MatchedPerk(
      category: 'Student Benefits',
      vendor: 'Figma',
      title: 'Figma Education',
      description:
          'Free education access to Figma Professional team features & FigJam whiteboard tools.',
      badgeText: '100% Free Pro',
      vendorColor: Color(0xFF047857),
      icon: Icons.design_services_outlined,
      logoUrl: 'assets/logos/figma.svg',
      iconBg: Color(0xFFE6FBF3),
    ),
    MatchedPerk(
      category: 'Student Benefits',
      vendor: 'Notion',
      title: 'Notion Education',
      description:
          'Free Education Plan for eligible students with unlimited file uploads & guest access.',
      badgeText: 'Free Pro Plan',
      vendorColor: Color(0xFF7E22CE),
      icon: Icons.note_alt_outlined,
      logoUrl: 'assets/logos/notion.svg',
      iconBg: Color(0xFFF3E8FF),
    ),
    MatchedPerk(
      category: 'Student Benefits',
      vendor: 'Unity',
      title: 'Unity Student Plan',
      description:
          'Free access to Unity Student Plan, real-time 3D development platform, and learning workflows.',
      badgeText: 'Free Access',
      vendorColor: Color(0xFF334155),
      icon: Icons.sports_esports_outlined,
      logoUrl: 'assets/logos/unity.svg',
      iconBg: Color(0xFFF1F5F9),
    ),
    MatchedPerk(
      category: 'Student Benefits',
      vendor: 'Autodesk',
      title: 'Autodesk Education',
      description:
          'Free educational access to AutoCAD, Fusion 360, Revit, and Maya for 1 year.',
      badgeText: 'Free Software',
      vendorColor: Color(0xFFEA580C),
      icon: Icons.architecture_rounded,
      logoUrl: 'assets/logos/autodesk.svg',
      iconBg: Color(0xFFFFEDD5),
    ),
    MatchedPerk(
      category: 'Student Benefits',
      vendor: 'Google Cloud',
      title: 'Google Cloud Skills Credits',
      description:
          '200 free learning credits for eligible students to complete hands-on GCP Qwiklabs.',
      badgeText: '200 Free Credits',
      vendorColor: Color(0xFF2563EB),
      icon: Icons.cloud_done_outlined,
      logoUrl: 'assets/logos/google_cloud.svg',
      iconBg: Color(0xFFEFF6FF),
    ),
    MatchedPerk(
      category: 'Student Benefits',
      vendor: 'AWS',
      title: 'AWS Educate',
      description:
          'Free cloud and AI learning modules, hands-on labs, and AWS cloud career pathways.',
      badgeText: 'Free Training',
      vendorColor: Color(0xFFD97706),
      icon: Icons.cloud_queue_rounded,
      logoUrl: 'assets/logos/aws.svg',
      iconBg: Color(0xFFFEF3C7),
    ),
    MatchedPerk(
      category: 'Student Benefits',
      vendor: 'IBM',
      title: 'IBM SkillsBuild',
      description:
          'Free AI, data science, cybersecurity, and career learning credentials for students.',
      badgeText: '100% Free',
      vendorColor: Color(0xFF1D4ED8),
      icon: Icons.psychology_outlined,
      logoUrl: 'assets/logos/ibm.svg',
      iconBg: Color(0xFFDBEAFE),
    ),

    // ------------------------------------------------
    // 2. STUDENT PLANS
    // ------------------------------------------------
    MatchedPerk(
      category: 'Student Plans',
      vendor: 'GitHub',
      title: 'GitHub Copilot Student',
      description:
          'Get AI pair programming assistant free while enrolled in a verified educational institution.',
      badgeText: 'Free AI Copilot',
      vendorColor: Color(0xFF4F46E5),
      icon: Icons.smart_toy_outlined,
      logoUrl: 'assets/logos/github.svg',
      iconBg: Color(0xFFE9E9FF),
    ),
    MatchedPerk(
      category: 'Student Plans',
      vendor: 'GitKraken',
      title: 'GitKraken Student Plan',
      description:
          'Free GitKraken Client Pro, GitLens Pro, and developer tools for student coders.',
      badgeText: 'Free Pro',
      vendorColor: Color(0xFF0284C7),
      icon: Icons.alt_route_rounded,
      logoUrl: 'assets/logos/gitkraken.svg',
      iconBg: Color(0xFFE0F2FE),
    ),
    MatchedPerk(
      category: 'Student Plans',
      vendor: 'MongoDB',
      title: 'MongoDB Student Benefits',
      description:
          '\$50 MongoDB Atlas credits, free certification voucher, and Compass GUI access.',
      badgeText: '\$50 Credits',
      vendorColor: Color(0xFF15803D),
      icon: Icons.storage_rounded,
      logoUrl: 'assets/logos/mongodb.svg',
      iconBg: Color(0xFFDCFCE7),
    ),
    MatchedPerk(
      category: 'Student Plans',
      vendor: 'DigitalOcean',
      title: 'DigitalOcean Student Credits',
      description:
          '\$200 cloud hosting credits for 1 year to deploy web apps, databases, and droplets.',
      badgeText: '\$200 Cloud Credit',
      vendorColor: Color(0xFF0284C7),
      icon: Icons.cloud_circle_rounded,
      logoUrl: 'assets/logos/digitalocean.svg',
      iconBg: Color(0xFFE0F2FE),
    ),
    MatchedPerk(
      category: 'Student Plans',
      vendor: 'Heroku',
      title: 'Heroku Student Credits',
      description:
          '\$13/month platform credits for 12 months to host apps, dynos, and databases.',
      badgeText: '\$156 Value',
      vendorColor: Color(0xFF6D28D9),
      icon: Icons.dns_rounded,
      logoUrl: 'assets/logos/heroku.svg',
      iconBg: Color(0xFFEDE9FE),
    ),
    MatchedPerk(
      category: 'Student Plans',
      vendor: 'Microsoft',
      title: 'Visual Studio Community',
      description:
          'Fully featured, extensible, free IDE for creating modern applications for Android, iOS, Windows.',
      badgeText: 'Free IDE',
      vendorColor: Color(0xFF2563EB),
      icon: Icons.code_off_rounded,
      logoUrl: 'assets/logos/microsoft.svg',
      iconBg: Color(0xFFEFF6FF),
    ),
    MatchedPerk(
      category: 'Student Plans',
      vendor: 'Canva',
      title: 'Canva Education Plan',
      description:
          'Free premium Canva templates, brand kits, and AI design tools for students and teachers.',
      badgeText: 'Free Pro Plan',
      vendorColor: Color(0xFFBE185D),
      icon: Icons.palette_outlined,
      logoUrl: 'assets/logos/canva.svg',
      iconBg: Color(0xFFFDE8F3),
    ),
    MatchedPerk(
      category: 'Student Plans',
      vendor: 'Miro',
      title: 'Miro Education Plan',
      description:
          'Free Education Plan with unlimited team whiteboards for project brainstorming & design.',
      badgeText: 'Free Unlimited',
      vendorColor: Color(0xFFD97706),
      icon: Icons.dashboard_customize_outlined,
      logoUrl: 'assets/logos/miro.svg',
      iconBg: Color(0xFFFEF3C7),
    ),

    // ------------------------------------------------
    // 3. FREE CERTIFICATIONS
    // ------------------------------------------------
    MatchedPerk(
      category: 'Free Certifications',
      vendor: 'IBM',
      title: 'IBM Digital Credentials',
      description:
          '100% free shareable digital badges in AI, Cybersecurity, Data Science, and Cloud Architecture.',
      badgeText: '🏆 Digital Badge',
      vendorColor: Color(0xFF1D4ED8),
      icon: Icons.workspace_premium_rounded,
      logoUrl: 'assets/logos/ibm.svg',
      iconBg: Color(0xFFDBEAFE),
    ),
    MatchedPerk(
      category: 'Free Certifications',
      vendor: 'Google Cloud',
      title: 'Google Cloud Skill Badges',
      description:
          'Earn official Google Cloud skill badges by completing hands-on lab challenges.',
      badgeText: '☁️ Skill Badge',
      vendorColor: Color(0xFF2563EB),
      icon: Icons.verified_sharp,
      logoUrl: 'assets/logos/google_cloud.svg',
      iconBg: Color(0xFFEFF6FF),
    ),
    MatchedPerk(
      category: 'Free Certifications',
      vendor: 'AWS',
      title: 'AWS Educate Badges',
      description:
          'Earn AWS learning badges upon completing cloud fundamentals, machine learning, and deep learning.',
      badgeText: '☁️ AWS Credential',
      vendorColor: Color(0xFFD97706),
      icon: Icons.badge_outlined,
      logoUrl: 'assets/logos/aws.svg',
      iconBg: Color(0xFFFEF3C7),
    ),
    MatchedPerk(
      category: 'Free Certifications',
      vendor: 'Cisco',
      title: 'Cisco Networking Academy',
      description:
          'Free networking, Python, and cybersecurity courses with verified completion credentials.',
      badgeText: '🌐 Cisco Cert',
      vendorColor: Color(0xFF0284C7),
      icon: Icons.router_outlined,
      logoUrl: 'assets/logos/cisco.svg',
      iconBg: Color(0xFFE0F2FE),
    ),
    MatchedPerk(
      category: 'Free Certifications',
      vendor: 'Microsoft',
      title: 'Microsoft Learn Achievements',
      description:
          'Free interactive learning paths with verifiable trophies and exam prep vouchers.',
      badgeText: '💻 MS Credentials',
      vendorColor: Color(0xFF0284C7),
      icon: Icons.school_rounded,
      logoUrl: 'assets/logos/microsoft.svg',
      iconBg: Color(0xFFE0F2FE),
    ),
    MatchedPerk(
      category: 'Free Certifications',
      vendor: 'Oracle',
      title: 'Oracle Academy Certification',
      description:
          'Free Java programming, database design, and SQL coursework with institutional certificates.',
      badgeText: '☕ Java/SQL Cert',
      vendorColor: Color(0xFFB91C1C),
      icon: Icons.data_object_rounded,
      logoUrl: 'assets/logos/oracle.svg',
      iconBg: Color(0xFFFEE2E2),
    ),
    MatchedPerk(
      category: 'Free Certifications',
      vendor: 'Salesforce',
      title: 'Salesforce Trailhead Badges',
      description:
          'Build cloud CRM and development skills while earning resume-ready Trailhead badges.',
      badgeText: '☁️ Trailhead Badge',
      vendorColor: Color(0xFF0284C7),
      icon: Icons.cloud_queue_rounded,
      logoUrl: 'assets/logos/salesforce.svg',
      iconBg: Color(0xFFE0F2FE),
    ),
    MatchedPerk(
      category: 'Free Certifications',
      vendor: 'NVIDIA',
      title: 'NVIDIA Deep Learning Institute',
      description:
          'Free AI, generative AI, and computer vision learning certificates for student researchers.',
      badgeText: '🤖 AI Certificate',
      vendorColor: Color(0xFF15803D),
      icon: Icons.memory_rounded,
      logoUrl: 'assets/logos/nvidia.svg',
      iconBg: Color(0xFFDCFCE7),
    ),
    MatchedPerk(
      category: 'Free Certifications',
      vendor: 'freeCodeCamp',
      title: 'freeCodeCamp Developer Certifications',
      description:
          'Verified 300-hour certifications in Responsive Web Design, JavaScript, Python, and Data Analysis.',
      badgeText: '💻 Free 300h Cert',
      vendorColor: Color(0xFF4F46E5),
      icon: Icons.code_rounded,
      logoUrl: 'assets/logos/freecodecamp.svg',
      iconBg: Color(0xFFE9E9FF),
    ),

    // ------------------------------------------------
    // 4. STUDENT DISCOUNTS
    // ------------------------------------------------
    MatchedPerk(
      category: 'Student Discounts',
      vendor: 'Adobe',
      title: 'Adobe Creative Cloud Discount',
      description:
          '60%+ student discount on Photoshop, Illustrator, Premiere Pro, and After Effects.',
      badgeText: '60% OFF',
      vendorColor: Color(0xFFB91C1C),
      icon: Icons.brush_outlined,
      logoUrl: 'assets/logos/adobe.svg',
      iconBg: Color(0xFFFEE2E2),
    ),
    MatchedPerk(
      category: 'Student Discounts',
      vendor: 'Coursera',
      title: 'Coursera Financial Aid',
      description:
          'Apply for up to 100% financial aid on university certificates from Meta, Google, and IBM.',
      badgeText: '100% Aid Option',
      vendorColor: Color(0xFF2563EB),
      icon: Icons.menu_book_rounded,
      logoUrl: 'assets/logos/coursera.svg',
      iconBg: Color(0xFFEFF6FF),
    ),
    MatchedPerk(
      category: 'Student Discounts',
      vendor: 'Udemy',
      title: 'Udemy Student Deals',
      description:
          'Up to 85% discount on top-rated development, design, and business courses.',
      badgeText: 'Up to 85% OFF',
      vendorColor: Color(0xFF7E22CE),
      icon: Icons.ondemand_video_rounded,
      logoUrl: 'assets/logos/udemy.svg',
      iconBg: Color(0xFFF3E8FF),
    ),
    MatchedPerk(
      category: 'Student Discounts',
      vendor: 'Namecheap',
      title: 'Namecheap Student Domain',
      description:
          'Free .me domain name for 1 year + discounted SSL certificate for portfolio projects.',
      badgeText: 'Free .me Domain',
      vendorColor: Color(0xFFC2410C),
      icon: Icons.language_rounded,
      logoUrl: 'assets/logos/namecheap.svg',
      iconBg: Color(0xFFFFEDD5),
    ),
    MatchedPerk(
      category: 'Student Discounts',
      vendor: 'Postman',
      title: 'Postman Student Expert',
      description:
          'Free Postman Student Expert digital badge, API training, and API platform tools.',
      badgeText: 'Free API Badge',
      vendorColor: Color(0xFFEA580C),
      icon: Icons.api_rounded,
      logoUrl: 'assets/logos/postman.svg',
      iconBg: Color(0xFFFFEDD5),
    ),
    MatchedPerk(
      category: 'Student Discounts',
      vendor: 'LinkedIn',
      title: 'LinkedIn Learning Access',
      description:
          'Free or discounted access through college library credentials to 16,000+ expert courses.',
      badgeText: 'Library Access',
      vendorColor: Color(0xFF0284C7),
      icon: Icons.cast_for_education_rounded,
      logoUrl: 'assets/logos/linkedin.svg',
      iconBg: Color(0xFFE0F2FE),
    ),
  ];

  String get _greetingName {
    final user = AuthService.instance.currentUser;
    final displayName = user?.displayName;
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim().split(' ').first;
    }
    return 'Ferbiya';
  }

  Future<void> _logout() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await AuthService.instance.signOut();
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not log out. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully.'),
        backgroundColor: Color(0xFF5B5FEF),
      ),
    );

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Widget _buildPerkLogo(MatchedPerk perk) {
    if (perk.logoUrl == null || perk.logoUrl!.isEmpty) {
      return Icon(perk.icon, color: perk.vendorColor, size: 28);
    }

    final logo = perk.logoUrl!;

    // 1. Local SVG asset (.svg)
    if (logo.endsWith('.svg')) {
      return SvgPicture.asset(
        logo,
        width: 52,
        height: 52,
        fit: BoxFit.contain,
      );
    }

    // 2. Local Image asset (.png, .jpg, .webp)
    if (logo.startsWith('assets/') || logo.startsWith('lib/')) {
      return Image.asset(
        logo,
        width: 52,
        height: 52,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          perk.icon,
          color: perk.vendorColor,
          size: 28,
        ),
      );
    }

    // 3. Network URL (http / https)
    return Image.network(
      logo,
      width: 52,
      height: 52,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        perk.icon,
        color: perk.vendorColor,
        size: 28,
      ),
    );
  }

  List<MatchedPerk> get _filteredPerks {
    if (_selectedCategoryIndex == 0) return _allMatchedPerks;
    final selectedCategory = _categories[_selectedCategoryIndex];
    return _allMatchedPerks
        .where((perk) => perk.category == selectedCategory)
        .toList();
  }

  void _applyMatchedPerk(MatchedPerk perk) {
    final p = findOrCreatePerk(
      name: perk.title,
      desc: perk.description,
      benefit: perk.badgeText,
    );
    PerkTracker.instance.setStatus(p, PerkStatus.applied);
    _snack('Applied to ${p.name}! Added to My Perks (Applied)');
  }

  void _applyPerk(String title, String desc, String benefit, String url) async {
    final p = findOrCreatePerk(
      name: title,
      desc: desc,
      benefit: benefit,
      url: url,
    );
    PerkTracker.instance.setStatus(p, PerkStatus.applied);
    _snack('Applied to ${p.name}! Added to My Perks (Applied)');
    if (url.isNotEmpty) {
      try {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFF5B5FEF),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  Widget _buildHomeBody() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF),
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF5B5FEF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'StudentPerk Hub',
              style: TextStyle(
                color: Color(0xFF172554),
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // NOTIFICATION BELL WITH RED BADGE
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No new notifications.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF172554),
                    size: 26,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFF64748B),
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: PerkTracker.instance,
          builder: (context, _) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // GREETING HEADER
              Text(
                'Hi, $_greetingName 👋',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172554),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your student perks, all in one place.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 18),

              // SEARCH BAR (REPLACING THE 33 BENEFITS BANNER)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search for offers, colleges, or benefits...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // FEATURED BANNER CARD CAROUSEL (3 ITEMS)
              SizedBox(
                height: 165,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _featuredBanners.length,
                  onPageChanged: (index) {
                    setState(() {
                      _heroPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final banner = _featuredBanners[index];
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF2835B1),
                            Color(0xFF1E2780),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2835B1).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: const Text(
                                          'FEATURED',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        banner.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.25,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        banner.subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFC7D2FE),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      InkWell(
                                        onTap: () => _applyPerk(
                                          banner.title,
                                          banner.subtitle,
                                          banner.title,
                                          banner.url,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'View Offer',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1E2780),
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 14,
                                                color: Color(0xFF1E2780),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Left Arrow
                          Positioned(
                            left: 8,
                            child: GestureDetector(
                              onTap: () {
                                final prev = (_heroPage - 1 + _featuredBanners.length) % _featuredBanners.length;
                                _pageController.animateToPage(
                                  prev,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.chevron_left_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Right Arrow
                          Positioned(
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                final next = (_heroPage + 1) % _featuredBanners.length;
                                _pageController.animateToPage(
                                  next,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // CAROUSEL DOTS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: index == _heroPage ? 8 : 6,
                    height: index == _heroPage ? 8 : 6,
                    decoration: BoxDecoration(
                      color: index == _heroPage
                          ? const Color(0xFF5B5FEF)
                          : const Color(0xFFCBD5E1),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // QUICK CATEGORIES HEADER & FOUR BOXES (REPLACING TOP FEATURED PERKS)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Categories',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172554),
                    ),
                  ),
                  InkWell(
                    onTap: () => _onTabTapped(1),
                    child: const Row(
                      children: [
                        Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5B5FEF),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Color(0xFF5B5FEF),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 2x2 QUICK CATEGORIES GRID (FOUR BOXES)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.55,
                children: [
                  _buildCategoryCard(
                    title: 'Student Benefits',
                    subtitle: 'Tools & resources',
                    icon: Icons.school_rounded,
                    iconBg: const Color(0xFFE9E9FF),
                    iconColor: const Color(0xFF5B5FEF),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StudentBenefitsScreen()),
                    ),
                  ),
                  _buildCategoryCard(
                    title: 'Student Plans',
                    subtitle: 'Special student pricing',
                    icon: Icons.code_rounded,
                    iconBg: const Color(0xFFE0E7FF),
                    iconColor: const Color(0xFF4338CA),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StudentPlansScreen()),
                    ),
                  ),
                  _buildCategoryCard(
                    title: 'Free Certifications',
                    subtitle: 'Build your skills',
                    icon: Icons.emoji_events_rounded,
                    iconBg: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FreeCertificationsScreen()),
                    ),
                  ),
                  _buildCategoryCard(
                    title: 'Discounts',
                    subtitle: 'Save more',
                    icon: Icons.percent_rounded,
                    iconBg: const Color(0xFFFEE2E2),
                    iconColor: const Color(0xFFEF4444),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DiscountsScreen()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // MATCHED PERKS HEADER & VERTICAL CARDS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Matched Perks (${_filteredPerks.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172554),
                      ),
                    ),
                    Text(
                      _selectedCategoryIndex == 0
                          ? 'All Categories'
                          : _categories[_selectedCategoryIndex],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5B5FEF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // MATCHED PERKS VERTICAL LIST
              Column(
                children: _filteredPerks.map((perk) {
                  final p = findOrCreatePerk(
                    name: perk.title,
                    desc: perk.description,
                    benefit: perk.badgeText,
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: perk.iconBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: perk.vendorColor.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: perk.vendorColor.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: _buildPerkLogo(perk),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    perk.vendor,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: perk.vendorColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    perk.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF172554),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListenableBuilder(
                              listenable: PerkTracker.instance,
                              builder: (context, _) {
                                final tracker = PerkTracker.instance;
                                final saved = tracker.isTracked(p);
                                return IconButton(
                                  icon: Icon(
                                    saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                    color: saved ? const Color(0xFF0B57D0) : null,
                                  ),
                                  onPressed: () => saved ? tracker.remove(p) : tracker.save(p),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          perk.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                perk.badgeText,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _applyMatchedPerk(perk),
                              child: const Row(
                                children: [
                                  Text(
                                    'Apply / Guide',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5B5FEF),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: Color(0xFF5B5FEF),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172554),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _buildHomeBody(),
          const ExploreScreen(),
          const VaultScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: _selectedTab == 0,
                  onTap: () => _onTabTapped(0),
                ),
                _NavItem(
                  icon: Icons.local_offer_outlined,
                  label: 'Explore',
                  isActive: _selectedTab == 1,
                  onTap: () => _onTabTapped(1),
                ),
                _NavItem(
                  icon: Icons.folder_outlined,
                  label: 'My Perks',
                  isActive: _selectedTab == 2,
                  onTap: () => _onTabTapped(2),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isActive: _selectedTab == 3,
                  onTap: () => _onTabTapped(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF5B5FEF) : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
