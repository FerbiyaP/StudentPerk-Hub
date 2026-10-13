import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bottom_navigation/Explore/explore_screen_data.dart';
import '../bottom_navigation/My_Perks/perks_tracker.dart';

class FreeCertificationsScreen extends StatefulWidget {
  const FreeCertificationsScreen({super.key});

  @override
  State<FreeCertificationsScreen> createState() => _FreeCertificationsScreenState();
}

class _FreeCertificationsScreenState extends State<FreeCertificationsScreen> {
  final _tracker = PerkTracker.instance;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final perks = <Perk>[];
    for (final cat in perkCategories) {
      for (final p in cat.perks) {
        if (p.desc.toLowerCase().contains('certificat') ||
            p.desc.toLowerCase().contains('course') ||
            p.benefit.toLowerCase().contains('certificat') ||
            p.name.toLowerCase().contains('skill') ||
            p.name.toLowerCase().contains('codecamp')) {
          if (_searchQuery.isEmpty ||
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.desc.toLowerCase().contains(_searchQuery.toLowerCase())) {
            perks.add(p);
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text('Free Certifications', style: TextStyle(color: Color(0xFF172554), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF172554)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search certifications & courses...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFD97706)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: perks.length,
              itemBuilder: (context, index) {
                final perk = perks[index];
                final tracked = _tracker.isTracked(perk);
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 1,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(perk.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF172554))),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(perk.desc, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(perk.benefit, style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w600, fontSize: 12)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        tracked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: tracked ? const Color(0xFFD97706) : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          if (tracked) {
                            _tracker.remove(perk);
                          } else {
                            _tracker.save(perk);
                          }
                        });
                      },
                    ),
                    onTap: () async {
                      _tracker.apply(perk);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text('Applied to ${perk.name}! Added to My Perks (Applied)'),
                              backgroundColor: const Color(0xFF5B5FEF),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                      }
                      if (perk.url.isNotEmpty) {
                        try {
                          await launchUrl(Uri.parse(perk.url), mode: LaunchMode.externalApplication);
                        } catch (_) {}
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
