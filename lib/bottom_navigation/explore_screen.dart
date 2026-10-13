import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Explore/explore_screen_data.dart';
import 'Explore/perk_logo.dart';
import 'My_Perks/perks_tracker.dart';

const _ink = Color(0xFF172554);
const _muted = Color(0xFF64748B);
const _accent = Color(0xFF5B5FEF);
const _bg = Color(0xFFF8F9FF);
const _line = Color(0xFFE2E8F0);

// Type colours: (text, background)
(Color, Color) _typeColors(PerkType t) => switch (t) {
  PerkType.free => (const Color(0xFF15803D), const Color(0xFFDCFCE7)),
  PerkType.credit => (const Color(0xFF1D4ED8), const Color(0xFFDBEAFE)),
  PerkType.discount => (const Color(0xFFC2410C), const Color(0xFFFFEDD5)),
  PerkType.trial => (const Color(0xFF7E22CE), const Color(0xFFF3E8FF)),
};

String _typeLabel(PerkType t) => switch (t) {
  PerkType.free => 'Free',
  PerkType.credit => 'Credit',
  PerkType.discount => 'Discount',
  PerkType.trial => 'Trial',
};

String _reqLabel(ReqKind k) => switch (k) {
  ReqKind.open => 'Open to all',
  ReqKind.email => 'College email',
  ReqKind.githubPack => 'GitHub Pack',
  ReqKind.verify => 'ID / verification',
  ReqKind.faculty => 'Faculty required',
  ReqKind.other => 'Student',
};

IconData _reqIcon(ReqKind k) => switch (k) {
  ReqKind.open => Icons.public_rounded,
  ReqKind.email => Icons.alternate_email_rounded,
  ReqKind.githubPack => Icons.code_rounded,
  ReqKind.verify => Icons.badge_outlined,
  ReqKind.faculty => Icons.account_balance_outlined,
  ReqKind.other => Icons.school_outlined,
};

String _reqExplain(ReqKind k) => switch (k) {
  ReqKind.open => 'No student proof needed.',
  ReqKind.email => 'You verify with your college email address.',
  ReqKind.githubPack =>
  'You need an approved GitHub Student Developer Pack first.',
  ReqKind.verify =>
  'Needs ID or third-party verification (for example SheerID, UNiDAYS or ID.me).',
  ReqKind.faculty =>
  'Your professor, IT department or administrator must register your institution first.',
  ReqKind.other => 'Check the eligibility rules on the official page.',
};

// Rows shown in the list
sealed class _Item {}

class _HeaderItem extends _Item {
  final PerkCategory cat;
  final int count;
  _HeaderItem(this.cat, this.count);
}

class _FacultyNoteItem extends _Item {}

class _PerkItem extends _Item {
  final Perk perk;
  final PerkCategory cat;
  final bool last;
  _PerkItem(this.perk, this.cat, this.last);
}

typedef OfferScreen = ExploreScreen;

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  PerkCategory? _category; // null = all
  PerkType? _type; // null = any
  ReqKind? _req; // null = any

  bool get _hasFilters =>
      _category != null ||
          _type != null ||
          _req != null ||
          _query.trim().isNotEmpty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearAll() {
    _searchController.clear();
    setState(() {
      _query = '';
      _category = null;
      _type = null;
      _req = null;
    });
  }

  bool _matches(Perk p) {
    if (_type != null && p.type != _type) return false;
    if (_req != null && p.reqKind != _req) return false;
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return p.name.toLowerCase().contains(q) ||
        p.desc.toLowerCase().contains(q) ||
        p.benefit.toLowerCase().contains(q);
  }

  /// Flattens categories + perks into one list so the screen can
  /// lazily build 150+ rows.
  (List<_Item>, int) _buildItems() {
    final items = <_Item>[];
    int total = 0;
    for (final cat in perkCategories) {
      if (_category != null && cat != _category) continue;
      final list = cat.perks.where(_matches).toList();
      if (list.isEmpty) continue;
      total += list.length;
      items.add(_HeaderItem(cat, list.length));
      if (cat.facultyOnly) items.add(_FacultyNoteItem());
      for (var i = 0; i < list.length; i++) {
        items.add(_PerkItem(list[i], cat, i == list.length - 1));
      }
    }
    return (items, total);
  }

  Future<void> _open(Perk p) async {
    try {
      final ok = await launchUrl(
        Uri.parse(p.url),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) _snack('Could not open ${p.name}');
    } catch (_) {
      _snack('Could not open ${p.name}');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final (items, total) = _buildItems();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Explore',
          style: TextStyle(
            color: _ink,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: PerkTracker.instance,
          builder: (context, _) => CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(child: _buildTopControls(total)),
              if (items.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: _buildEmpty())
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildItem(items[index]),
                    childCount: items.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------
  // SEARCH + FILTERS
  // ------------------------------------------------
  Widget _buildTopControls(int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search $totalPerks perks, brands, tools',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, color: _muted),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.close_rounded, color: _muted),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: _line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: _line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: _accent, width: 1.5),
              ),
            ),
          ),
        ),

        // Category row
        _chipRow([
          _FilterChipData('All', _category == null, () {
            setState(() => _category = null);
          }),
          for (final c in perkCategories)
            _FilterChipData(c.shortTitle, _category == c, () {
              setState(() => _category = _category == c ? null : c);
            }),
        ]),
        const SizedBox(height: 8),

        // Type row
        _chipRow([
          _FilterChipData('Any type', _type == null, () {
            setState(() => _type = null);
          }),
          for (final t in PerkType.values)
            _FilterChipData(_typeLabel(t), _type == t, () {
              setState(() => _type = _type == t ? null : t);
            }),
        ]),
        const SizedBox(height: 8),

        // Requirement row
        _chipRow([
          _FilterChipData('Any requirement', _req == null, () {
            setState(() => _req = null);
          }),
          for (final k in const [
            ReqKind.open,
            ReqKind.email,
            ReqKind.githubPack,
            ReqKind.verify,
            ReqKind.faculty,
          ])
            _FilterChipData(_reqLabel(k), _req == k, () {
              setState(() => _req = _req == k ? null : k);
            }),
        ]),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$total ${total == 1 ? 'perk' : 'perks'}',
                  style: const TextStyle(
                    color: _muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              if (_hasFilters)
                TextButton(
                  onPressed: _clearAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Clear filters',
                    style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Offers come from a community-maintained list and some are limited '
                'to certain countries. Always confirm eligibility on the official page.',
            style: TextStyle(color: _muted, fontSize: 12, height: 1.35),
          ),
        ),
      ],
    );
  }

  Widget _chipRow(List<_FilterChipData> chips) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = chips[i];
          return GestureDetector(
            onTap: c.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.selected ? _accent : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.selected ? _accent : _line),
              ),
              child: Text(
                c.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.selected ? Colors.white : _muted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------
  // LIST ROWS
  // ------------------------------------------------
  Widget _buildItem(_Item item) {
    return switch (item) {
      _HeaderItem h => _buildHeader(h),
      _FacultyNoteItem _ => _buildFacultyNote(),
      _PerkItem p => _buildPerkTile(p),
    };
  }

  Widget _buildHeader(_HeaderItem h) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: h.cat.tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(h.cat.icon, color: h.cat.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h.cat.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                Text(
                  h.cat.blurb,
                  style: const TextStyle(fontSize: 12, color: _muted),
                ),
              ],
            ),
          ),
          Text(
            '${h.count}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: h.cat.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyNote() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF92400E)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'These benefits cannot be claimed by students alone. Your '
                  'professor, IT department or school administrator must register '
                  'your institution first.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerkTile(_PerkItem item) {
    final p = item.perk;
    final kind = p.reqKind;
    final (typeFg, _) = _typeColors(p.type);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDetail(p, item.cat),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PerkLogo(perk: p, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          p.desc,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5, color: _muted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.benefit,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: typeFg,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _TypePill(type: p.type),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_reqIcon(kind), size: 14, color: _muted),
                                const SizedBox(width: 4),
                                Text(
                                  p.req,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _muted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: ListenableBuilder(
                      listenable: PerkTracker.instance,
                      builder: (context, _) {
                        final tracker = PerkTracker.instance;
                        final saved = tracker.isTracked(p);
                        return IconButton(
                          icon: Icon(
                            saved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: saved ? const Color(0xFF0B57D0) : null,
                          ),
                          onPressed: () =>
                          saved ? tracker.remove(p) : tracker.save(p),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!item.last)
          const Divider(height: 1, indent: 82, endIndent: 0, color: _line),
      ],
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          const Text(
            'No matching perks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try a different word or remove a filter.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _clearAll,
            child: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------
  // DETAIL SHEET
  // ------------------------------------------------
  void _showDetail(Perk p, PerkCategory cat) {
    final kind = p.reqKind;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ListenableBuilder(
        listenable: PerkTracker.instance,
        builder: (context, _) {
          final isSaved = PerkTracker.instance.isTracked(p);
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      PerkLogo(perk: p, size: 56),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                            ),
                            Text(
                              '${p.desc} · ${cat.shortTitle}',
                              style: const TextStyle(color: _muted),
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
                              saved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: saved ? const Color(0xFF0B57D0) : null,
                            ),
                            onPressed: () =>
                            saved ? tracker.remove(p) : tracker.save(p),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _detailBlock('What you get', p.benefit,
                      trailing: _TypePill(type: p.type)),
                  _detailBlock(
                    'Who can claim',
                    p.req,
                    note: _reqExplain(kind),
                    icon: _reqIcon(kind),
                  ),
                  if (kind == ReqKind.faculty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Ask your professor or IT department to register first, '
                            'then you can sign in with your college account.',
                        style:
                        TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                      ),
                    ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        PerkTracker.instance.apply(p);
                        Navigator.pop(ctx);
                        _open(p);
                        _snack(
                            'Applied to ${p.name}! Added to My Perks (Applied)');
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded,
                          size: 18),
                      label: const Text('Apply & Open official page'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            PerkTracker.instance.activate(p);
                            Navigator.pop(ctx);
                            _snack(
                                'Marked ${p.name} as Active (Currently used)');
                          },
                          icon: const Icon(Icons.flash_on_rounded,
                              size: 16, color: Color(0xFF16A34A)),
                          label: const Text('Use (Active)',
                              style: TextStyle(
                                  color: Color(0xFF16A34A), fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF16A34A)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            PerkTracker.instance.markExpiring(p);
                            Navigator.pop(ctx);
                            _snack('Marked ${p.name} as Expiring');
                          },
                          icon: const Icon(Icons.timer_outlined,
                              size: 16, color: Color(0xFFEF4444)),
                          label: const Text('Expiring',
                              style: TextStyle(
                                  color: Color(0xFFEF4444), fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (isSaved) {
                          PerkTracker.instance.remove(p);
                          _snack('Removed ${p.name} from My Perks');
                        } else {
                          PerkTracker.instance.save(p);
                          _snack('Saved ${p.name} to My Perks (Saved)');
                        }
                      },
                      icon: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        size: 18,
                        color: isSaved ? _accent : _ink,
                      ),
                      label: Text(
                        isSaved ? 'Remove from My Perks' : 'Save to My Perks',
                        style: TextStyle(
                          color: isSaved ? _accent : _ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isSaved ? _accent : _ink,
                        side: BorderSide(color: isSaved ? _accent : _line),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _open(p);
                      },
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('Open official page only'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _ink,
                        side: const BorderSide(color: _line),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _detailBlock(
      String label,
      String value, {
        String? note,
        IconData? icon,
        Widget? trailing,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: _muted,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: _ink),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ),
              ...?trailing == null ? null : [trailing],
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 4),
            Text(note,
                style:
                const TextStyle(fontSize: 13, color: _muted, height: 1.4)),
          ],
        ],
      ),
    );
  }
}

// ------------------------------------------------
// SMALL WIDGETS
// ------------------------------------------------
class _FilterChipData {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  _FilterChipData(this.label, this.selected, this.onTap);
}

class _TypePill extends StatelessWidget {
  final PerkType type;
  const _TypePill({required this.type});

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = _typeColors(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _typeLabel(type).toUpperCase(),
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: fg,
        ),
      ),
    );
  }
}