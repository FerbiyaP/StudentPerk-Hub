import 'package:flutter/foundation.dart';
import 'explore_screen_data.dart';

class PerkRepository extends ChangeNotifier {
  static final PerkRepository instance = PerkRepository._();
  PerkRepository._();

  List<PerkCategory> _categories = perkCategories;
  List<PerkCategory> get categories => _categories;

  bool _isLive = true;
  bool get isLive => _isLive;

  void start() {
    _categories = perkCategories;
    _isLive = true;
    notifyListeners();
  }

  PerkCategory categoryOf(Perk p) {
    for (final c in _categories) {
      if (c.perks.any((x) => x.name == p.name)) {
        return c;
      }
    }
    return _categories.first;
  }

  Perk? find(String name) {
    for (final c in _categories) {
      for (final p in c.perks) {
        if (p.name.trim().toLowerCase() == name.trim().toLowerCase()) {
          return p;
        }
      }
    }
    return null;
  }

  Future<void> seedFromBundled() async {
    debugPrint('Using bundled static perks (offline mode).');
  }
}
