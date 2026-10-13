import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Explore/explore_screen_data.dart';

enum PerkStatus { saved, applied, active, expiring }

class TrackedPerk {
  final Perk perk;
  PerkStatus status;
  DateTime? renewsOn;

  TrackedPerk(this.perk, this.status, {this.renewsOn});

  Map<String, dynamic> toJson() => {
    'name': perk.name,
    'status': status.name,
    'renewsOn': renewsOn?.toIso8601String(),
  };

  factory TrackedPerk.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    final perk = _findPerkStatic(name) ?? Perk(
      name,
      '',
      '',
      PerkType.discount,
      '',
      '',
    );
    final statusName = json['status'] as String? ?? 'saved';
    final status = PerkStatus.values.firstWhere(
          (s) => s.name == statusName,
      orElse: () => PerkStatus.saved,
    );
    final renewsStr = json['renewsOn'] as String?;
    final renewsOn = renewsStr != null ? DateTime.tryParse(renewsStr) : null;
    return TrackedPerk(perk, status, renewsOn: renewsOn);
  }
}

Perk? _findPerkStatic(String name) {
  for (final c in perkCategories) {
    for (final p in c.perks) {
      if (p.name == name) return p;
    }
  }
  return null;
}

/// SharedPreferences-backed store shared by Explore, Home and My Perks.
class PerkTracker extends ChangeNotifier {
  PerkTracker._();

  static final PerkTracker instance = PerkTracker._();

  final Map<String, TrackedPerk> _items = {};
  bool _started = false;

  // ---------------- lifecycle ----------------

  Future<void> init() async {
    if (_started) return;
    _started = true;
    await _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listStr = prefs.getStringList('tracked_perks_list') ?? [];
      _items.clear();
      for (final itemStr in listStr) {
        try {
          final data = jsonDecode(itemStr) as Map<String, dynamic>;
          final tracked = TrackedPerk.fromJson(data);
          _items[tracked.perk.name] = tracked;
        } catch (_) {}
      }
      notifyListeners();
    } catch (e) {
      debugPrint('PerkTracker load error: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listStr = _items.values.map((t) => jsonEncode(t.toJson())).toList();
      await prefs.setStringList('tracked_perks_list', listStr);
    } catch (e) {
      debugPrint('PerkTracker save error: $e');
    }
  }

  void _put(TrackedPerk t) {
    _items[t.perk.name] = t;
    notifyListeners();
    _saveToPrefs();
  }

  Future<void> importPerks(List<TrackedPerk> items) async {
    for (final t in items) {
      if (!_items.containsKey(t.perk.name)) {
        _items[t.perk.name] = t;
      }
    }
    notifyListeners();
    await _saveToPrefs();
  }

  // ---------------- public API ----------------

  List<TrackedPerk> get all => _items.values.toList();

  bool isTracked(Perk p) => _items.containsKey(p.name);

  TrackedPerk? of(Perk p) => _items[p.name];

  void save(Perk p) {
    if (_items.containsKey(p.name)) return;
    _put(TrackedPerk(p, PerkStatus.saved));
  }

  void apply(Perk p) => setStatus(p, PerkStatus.applied);

  void activate(Perk p) => setStatus(p, PerkStatus.active);

  void markExpiring(Perk p, {DateTime? renewsOn}) =>
      setStatus(p, PerkStatus.expiring, renewsOn: renewsOn);

  void setStatus(Perk p, PerkStatus status, {DateTime? renewsOn}) {
    final t = _items[p.name];
    if (t == null) {
      _put(TrackedPerk(p, status, renewsOn: renewsOn));
    } else {
      t.status = status;
      if (renewsOn != null) t.renewsOn = renewsOn;
      _put(t);
    }
  }

  void setRenewal(Perk p, DateTime date) {
    final t = _items[p.name];
    if (t == null) {
      _put(TrackedPerk(p, PerkStatus.expiring, renewsOn: date));
    } else {
      t.renewsOn = date;
      t.status = PerkStatus.expiring;
      _put(t);
    }
  }

  void remove(Perk p) {
    if (_items.remove(p.name) == null) return;
    notifyListeners();
    _saveToPrefs();
  }

  void restore(TrackedPerk t) => _put(t);
}
