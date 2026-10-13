import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';

import 'explore_screen_data.dart';
import 'perk_repository.dart';

PerkCategory categoryOfPerk(Perk p) => PerkRepository.instance.categoryOf(p);

String perkMonogram(String name) {
  final words = name
      .split(RegExp(r'[^A-Za-z0-9]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return '?';
  if (words.length == 1) return words.first[0].toUpperCase();
  return (words[0][0] + words[1][0]).toUpperCase();
}

// Perks whose tile should always be dark (as in the design).
const Set<String> _darkTilePerks = {'Termius', 'Figma'};

const Color _darkTile = Color(0xFF111111);

// ---------------------------------------------------------------
// SVG loading + colour analysis (cached, so each file is read once)
// ---------------------------------------------------------------
class _LogoData {
  final String? svg;
  final bool lightOnly; // every colour in the file is near-white
  const _LogoData(this.svg, this.lightOnly);
}

final Map<String, Future<_LogoData>> _cache = {};

Future<_LogoData> _load(String path) => _cache.putIfAbsent(path, () async {
  try {
    final raw = await rootBundle.loadString(path);
    return _LogoData(raw, _isLightOnly(raw));
  } catch (_) {
    return const _LogoData(null, false); // missing asset
  }
});

bool _isLightOnly(String svg) {
  final re = RegExp(
      r'''(?:fill|stroke|stop-color)\s*[:=]\s*["']?\s*(#[0-9a-fA-F]{3,8}|[a-zA-Z]+)''');
  const skip = {'none', 'currentcolor', 'transparent', 'inherit', 'url'};
  var found = 0;
  for (final m in re.allMatches(svg)) {
    final v = m.group(1)!.toLowerCase();
    if (skip.contains(v)) continue;
    found++;
    if (!_isLight(v)) return false;
  }
  return found > 0;
}

bool _isLight(String v) {
  if (v == 'white') return true;
  if (!v.startsWith('#')) return false;
  var h = v.substring(1);
  if (h.length == 3) h = h.split('').map((c) => '$c$c').join();
  if (h.length < 6) return false;
  final r = int.tryParse(h.substring(0, 2), radix: 16);
  final g = int.tryParse(h.substring(2, 4), radix: 16);
  final b = int.tryParse(h.substring(4, 6), radix: 16);
  if (r == null || g == null || b == null) return false;
  return (0.299 * r + 0.587 * g + 0.114 * b) / 255 > 0.88;
}

// ---------------------------------------------------------------
// Widget: use PerkLogo(perk: perk, size: 48) everywhere.
// ---------------------------------------------------------------
class PerkLogo extends StatelessWidget {
  final Perk perk;
  final double size;
  const PerkLogo({super.key, required this.perk, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final cat = categoryOfPerk(perk);
    final path = perkLogos[perk.name];
    final forceDark = _darkTilePerks.contains(perk.name);

    if (path == null) {
      return _shell(Colors.white, _fallback(cat.color));
    }

    return FutureBuilder<_LogoData>(
      future: _load(path),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _shell(Colors.white, const SizedBox.shrink());
        }
        final data = snap.data;
        if (data == null || data.svg == null) {
          return _shell(Colors.white, _fallback(cat.color));
        }
        // Light-only (white) logos and the forced-dark perks get a black tile.
        final dark = data.lightOnly || forceDark;
        return _shell(
          dark ? _darkTile : Colors.white,
          SvgPicture.string(
            data.svg!,
            fit: BoxFit.contain,
            theme: SvgTheme(
              currentColor: dark ? Colors.white : const Color(0xFF111111),
            ),
            placeholderBuilder: (_) => const SizedBox.shrink(),
            errorBuilder: (_, _, _) => _fallback(cat.color),
          ),
        );
      },
    );
  }

  // White/black rounded tile with a soft shadow, no border.
  Widget _shell(Color bg, Widget child) => Container(
    width: size,
    height: size,
    padding: EdgeInsets.all(size * 0.24),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(size * 0.3),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Center(child: child),
  );

  Widget _fallback(Color color) {
    Widget initials() => Text(
      perkMonogram(perk.name),
      style: TextStyle(
        color: color,
        fontSize: size * 0.34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    );

    final host = Uri.tryParse(perk.url)?.host ?? '';
    if (host.isEmpty) return initials();

    return Image.network(
      'https://www.google.com/s2/favicons?domain=$host&sz=128',
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => initials(),
    );
  }
}