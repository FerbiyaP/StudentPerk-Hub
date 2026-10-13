import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/auth_service.dart';
import 'Explore/explore_screen_data.dart';
import 'My_Perks/perks_tracker.dart';

const _accent = Color(0xFF0B57D0);
const _accentSoft = Color(0xFFD3E3FD);
const _ink = Color(0xFF1B1C20);
const _grey = Color(0xFF5F6368);
const _line = Color(0xFFE3E5EA);
const _green = Color(0xFF146C2E);
const _red = Color(0xFFB3261E);

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _statusLabel(PerkStatus s) => switch (s) {
  PerkStatus.saved => 'Saved',
  PerkStatus.applied => 'Applied',
  PerkStatus.active => 'Active',
  PerkStatus.expiring => 'Expiring',
};

String _fmt(DateTime d) => '${d.day} ${_months[d.month - 1]}';

PerkCategory _categoryOf(Perk p) =>
    perkCategories.firstWhere((c) => c.perks.contains(p),
        orElse: () => perkCategories.first);

String _monogram(String name) {
  final words = name
      .split(RegExp(r'[^A-Za-z0-9]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return '?';
  if (words.length == 1) return words.first[0].toUpperCase();
  return (words[0][0] + words[1][0]).toUpperCase();
}

class MyPerksScreen extends StatefulWidget {
  const MyPerksScreen({super.key});

  @override
  State<MyPerksScreen> createState() => _MyPerksScreenState();
}

// Keeps your existing navigation code working.
typedef VaultScreen = MyPerksScreen;

class _MyPerksScreenState extends State<MyPerksScreen>
    with SingleTickerProviderStateMixin {
  final _tracker = PerkTracker.instance;
  late TabController _tabs;
  bool _tabsInitialized = false;

  static const _tabLabels = ['All', 'Saved', 'Applied', 'Active', 'Expiring'];

  @override
  void initState() {
    super.initState();
    _initTabs();
  }

  void _initTabs() {
    if (_tabsInitialized) return;
    _tabs = TabController(length: _tabLabels.length, vsync: this);
    _tabs.addListener(_onTabChanged);
    _tabsInitialized = true;
  }

  Widget _buildBackupCard(BuildContext context) {
    if (!AuthService.instance.isAnonymous) return const SizedBox.shrink();
    return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD3E3FD)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Back up your perks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1C20),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Link your Google account so you never lose your saved and applied perks.',
                style: TextStyle(fontSize: 13, color: Color(0xFF5F6368)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final err = await AuthService.instance.linkGoogle();
                    if (err != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                    }
                  },
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                  label: const Text('Link Google Account'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0B57D0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
  }

  void _onTabChanged() {
    if (!_tabs.indexIsChanging && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (_tabsInitialized) {
      _tabs.removeListener(_onTabChanged);
      _tabs.dispose();
    }
    super.dispose();
  }

  List<TrackedPerk> _filtered(List<TrackedPerk> all) {
    _initTabs();
    final i = _tabs.index;
    final list = i == 0
        ? all
        : all.where((t) => t.status == PerkStatus.values[i - 1]).toList();
    list.sort((a, b) => a.perk.name.compareTo(b.perk.name));
    return list;
  }

  void _remove(TrackedPerk t) {
    _tracker.remove(t.perk);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Removed ${t.perk.name}'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _tracker.restore(t),
          ),
        ),
      );
  }

  Future<void> _openUrl(Perk p) async {
    try {
      final ok = await launchUrl(
        Uri.parse(p.url),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) _toast('Could not open ${p.name}');
    } catch (_) {
      _toast('Could not open ${p.name}');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: const Text(
          'My perks',
          style: TextStyle(
            color: _ink,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _tracker,
          builder: (context, _) {
            final all = _tracker.all;
            final items = _filtered(all);
            final active =
                all.where((t) => t.status == PerkStatus.active).length;
            final expiring =
                all.where((t) => t.status == PerkStatus.expiring).length;

            return Column(
              children: [
                _buildBackupCard(context),
                _Summary(total: all.length, active: active, expiring: expiring),
                _buildTabs(),
                Expanded(
                  child: items.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: items.length,
                    itemBuilder: (context, i) => _buildRow(
                      items[i],
                      showDivider: i != items.length - 1,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ------------------------------------------------
  // TABS (underline style)
  // ------------------------------------------------
  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: TabBar(
        controller: _tabs,
        labelColor: _accent,
        unselectedLabelColor: _grey,
        indicatorColor: _accent,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        unselectedLabelStyle:
        const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        tabs: [for (final l in _tabLabels) Tab(height: 48, text: l)],
      ),
    );
  }

  // ------------------------------------------------
  // LIST ROW
  // ------------------------------------------------
  Widget _buildRow(TrackedPerk t, {required bool showDivider}) {
    final p = t.perk;
    final expiring = t.status == PerkStatus.expiring;
    final statusText = expiring
        ? (t.renewsOn != null
        ? 'Renews ${_fmt(t.renewsOn!)}'
        : 'Expiring soon')
        : _statusLabel(t.status);

    return Column(
      children: [
        InkWell(
          onTap: () => _showDetail(t),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
            child: Row(
              children: [
                _Monogram(perk: p),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${p.desc} · ${p.req}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13.5, color: _grey),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: expiring ? _red : _green,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove from my perks',
                  onPressed: () => _remove(t),
                  icon: const Icon(Icons.bookmark_rounded, color: _accent),
                  iconSize: 28,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 78, endIndent: 0, color: _line),
      ],
    );
  }

  Widget _buildEmpty() {
    final tab = _tabs.index == 0 ? '' : '${_tabLabels[_tabs.index].toLowerCase()} ';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmark_border_rounded, size: 48, color: _grey),
            const SizedBox(height: 12),
            Text(
              'No ${tab}perks yet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap the bookmark on any perk in Explore to track it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _grey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------
  // DETAIL / EDIT SHEET
  // ------------------------------------------------
  void _showDetail(TrackedPerk t) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (ctx) => ListenableBuilder(
        listenable: _tracker,
        builder: (context, _) {
          final cur = _tracker.of(t.perk);
          if (cur == null) return const SizedBox.shrink();
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _Monogram(perk: cur.perk, size: 56),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cur.perk.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: _ink,
                              ),
                            ),
                            Text(
                              cur.perk.benefit,
                              style: const TextStyle(color: _green, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your status',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final s in PerkStatus.values)
                        ChoiceChip(
                          label: Text(_statusLabel(s)),
                          selected: cur.status == s,
                          selectedColor: _accentSoft,
                          showCheckmark: true,
                          onSelected: (_) => _tracker.setStatus(cur.perk, s),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final now = DateTime.now();
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: cur.renewsOn ?? now.add(const Duration(days: 30)),
                        firstDate: now.subtract(const Duration(days: 365)),
                        lastDate: now.add(const Duration(days: 365 * 5)),
                        helpText: 'Renewal or expiry date',
                      );
                      if (d != null) _tracker.setRenewal(cur.perk, d);
                    },
                    icon: const Icon(Icons.event_outlined, size: 18),
                    label: Text(
                      cur.renewsOn == null
                          ? 'Set renewal date'
                          : 'Renews ${_fmt(cur.renewsOn!)} ${cur.renewsOn!.year}',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accent,
                      side: const BorderSide(color: _line),
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openUrl(cur.perk);
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Open official page'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _accent,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _remove(cur);
                      },
                      child: const Text(
                        'Remove from my perks',
                        style: TextStyle(color: _red, fontWeight: FontWeight.w500),
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
}

// ------------------------------------------------
// SMALL WIDGETS
// ------------------------------------------------
class _Summary extends StatelessWidget {
  final int total;
  final int active;
  final int expiring;
  const _Summary({
    required this.total,
    required this.active,
    required this.expiring,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$total',
            style: const TextStyle(
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w500,
              color: _ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                total == 1 ? 'perk tracked' : 'perks tracked',
                style: const TextStyle(fontSize: 14, color: _grey),
              ),
            ),
          ),
          Text(
            '$active active',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _green,
            ),
          ),
          if (expiring > 0) ...[
            const Text('  ·  ', style: TextStyle(color: _grey)),
            Text(
              '$expiring expiring',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _red,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Solid coloured square with white initials, as in the reference.
/// To show your SVG brand logos instead, swap the Text for
/// SvgPicture.asset(perkLogos[perk.name]!) when that key exists.
class _Monogram extends StatelessWidget {
  final Perk perk;
  final double size;
  const _Monogram({required this.perk, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final logoPath = perkLogos[perk.name];
    if (logoPath != null && logoPath.endsWith('.svg')) {
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size * 0.22),
          border: Border.all(color: const Color(0xFFE3E5EA)),
        ),
        child: SvgPicture.asset(
          logoPath,
          fit: BoxFit.contain,
        ),
      );
    }

    final color = _categoryOf(perk).color;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Text(
        _monogram(perk.name),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}