import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;

  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> onboardingData = [
    {
      'icon': Icons.local_offer_rounded,
      'title': 'Discover Student Discounts',
      'description':
      'Find exclusive discounts on software, learning platforms, food, travel, and more.',
    },
    {
      'icon': Icons.workspace_premium_rounded,
      'title': 'Get Student Benefits',
      'description':
      'Access certifications, cloud credits, premium tools, and other student perks.',
    },
    {
      'icon': Icons.track_changes_rounded,
      'title': 'Track Your Benefits',
      'description':
      'Keep all your student benefits in one place and never miss an expiry date.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void nextPage() {
    if (currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      goToLogin();
    }
  }

  void goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // ------------------------------------------------
            // SKIP BUTTON
            // ------------------------------------------------
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 20),
                child: TextButton(
                  onPressed: goToLogin,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),

            // ------------------------------------------------
            // PAGE VIEW
            // ------------------------------------------------
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = onboardingData[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ILLUSTRATION CONTAINER
                        Container(
                          width: 270,
                          height: 270,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9E9FF),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Decorative circles
                              Positioned(
                                top: 25,
                                right: 25,
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5B5FEF)
                                        .withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 30,
                                left: 25,
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5B5FEF)
                                        .withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              // Main icon
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  page['icon'],
                                  size: 75,
                                  color: const Color(0xFF5B5FEF),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 45),

                        // TITLE
                        Text(
                          page['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF172554),
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // DESCRIPTION
                        Text(
                          page['description'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ------------------------------------------------
            // PAGE INDICATORS
            // ------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                    (index) {
                  bool isActive = currentPage == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF5B5FEF)
                          : const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // GET STARTED BUTTON
            // ------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B5FEF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    currentPage == onboardingData.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}