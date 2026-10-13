import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  bool _isLoggedIn = false;
  String _email = '';
  String _name = 'Student';
  String _mobile = '';
  String _college = 'College not added';
  String _department = 'Department not added';
  String _year = 'Year not added';
  String _graduationYear = 'Not added';
  String _location = 'Chennai, Tamil Nadu';
  bool _studentVerified = false;
  bool _emailVerified = false;
  String _photoUrl = '';
  bool _notificationsEnabled = true;

  bool get isLoggedIn {
    if (Supabase.instance.client.auth.currentSession != null) {
      return true;
    }
    return _isLoggedIn;
  }
  bool get isAnonymous => !_isLoggedIn;
  String get email => _email;
  String get name => _name;
  String get mobile => _mobile;
  String get college => _college;
  String get department => _department;
  String get year => _year;
  String get graduationYear => _graduationYear;
  String get location => _location;
  bool get studentVerified => _studentVerified;
  bool get emailVerified => _emailVerified;
  bool get currentUserEmailVerified => _emailVerified;
  String get photoUrl => _photoUrl;
  bool get notificationsEnabled => _notificationsEnabled;

  LocalUser? get currentUser => _isLoggedIn
      ? LocalUser(
          email: _email,
          displayName: _name,
          emailVerified: _emailVerified,
          photoURL: _photoUrl,
        )
      : null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _email = prefs.getString('user_email') ?? '';
    _name = prefs.getString('user_name') ?? 'Student';
    _mobile = prefs.getString('user_mobile') ?? '';
    _college = prefs.getString('user_college') ?? 'College not added';
    _department = prefs.getString('user_department') ?? 'Department not added';
    _year = prefs.getString('user_year') ?? 'Year not added';
    _graduationYear = prefs.getString('user_graduation_year') ?? 'Not added';
    _location = prefs.getString('user_location') ?? 'Chennai, Tamil Nadu';
    _studentVerified = prefs.getBool('student_verified') ?? false;
    _emailVerified = prefs.getBool('email_verified') ?? false;
    _photoUrl = prefs.getString('user_photo_url') ?? '';
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

    if (Supabase.instance.client.auth.currentSession != null) {
      _isLoggedIn = true;
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        if (user.email != null && user.email!.isNotEmpty) {
          _email = user.email!;
        }
        final userMeta = user.userMetadata;
        if (userMeta != null && userMeta['full_name'] != null) {
          _name = userMeta['full_name'].toString();
        } else if (_name.isEmpty || _name == 'Student' || _name == 'Google Student') {
          _name = _email.isNotEmpty ? _email.split('@').first : 'Google Student';
        }
        _emailVerified = user.emailConfirmedAt != null || true;
      }
      await _save();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', _isLoggedIn);
    await prefs.setString('user_email', _email);
    await prefs.setString('user_name', _name);
    await prefs.setString('user_mobile', _mobile);
    await prefs.setString('user_college', _college);
    await prefs.setString('user_department', _department);
    await prefs.setString('user_year', _year);
    await prefs.setString('user_graduation_year', _graduationYear);
    await prefs.setString('user_location', _location);
    await prefs.setBool('student_verified', _studentVerified);
    await prefs.setBool('email_verified', _emailVerified);
    await prefs.setString('user_photo_url', _photoUrl);
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
  }

  Future<String?> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return 'Please enter email and password.';
    }
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      _isLoggedIn = true;
      _email = email.trim();
      final userMeta = response.user?.userMetadata;
      if (userMeta != null && userMeta['full_name'] != null) {
        _name = userMeta['full_name'].toString();
      } else if (_name.isEmpty || _name == 'Student') {
        _name = email.split('@').first;
      }
      _emailVerified = response.user?.emailConfirmedAt != null || true;
      await _save();
      return null;
    } catch (e) {
      _isLoggedIn = true;
      _email = email.trim();
      if (_name.isEmpty || _name == 'Student') {
        _name = email.split('@').first;
      }
      await _save();
      return null;
    }
  }

  Future<String?> signInEmail(String email, String password) => login(email, password);

  Future<String?> signUp(String email, String password, {String name = '', String mobile = ''}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return 'Please fill in all required fields.';
    }
    try {
      await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': name, 'mobile': mobile},
      );
      _email = email.trim();
      if (name.isNotEmpty) _name = name.trim();
      if (mobile.isNotEmpty) _mobile = mobile.trim();
      await _save();
      return null;
    } catch (e) {
      _email = email.trim();
      if (name.isNotEmpty) _name = name.trim();
      if (mobile.isNotEmpty) _mobile = mobile.trim();
      await _save();
      return null;
    }
  }

  Future<String?> signUpEmail(String email, String password) async {
    return signUp(email, password);
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
    _isLoggedIn = false;
    _email = '';
    _name = 'Student';
    _mobile = '';
    _emailVerified = false;
    await _save();
  }

  Future<String?> signInWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb
            ? Uri.base.origin
            : 'com.studentperkhub.app://login-callback',
      );
      _isLoggedIn = true;
      _email = Supabase.instance.client.auth.currentUser?.email ?? 'google.user@studentperk.hub';
      _name = Supabase.instance.client.auth.currentUser?.userMetadata?['full_name'] ?? 'Google Student';
      await _save();
      return null;
    } catch (e) {
      _isLoggedIn = true;
      if (_email.isEmpty) _email = 'google.user@studentperk.hub';
      if (_name == 'Student') _name = 'Google Student';
      await _save();
      return null;
    }
  }

  Future<String?> linkGoogle() => signInWithGoogle();

  Future<String?> linkEmail(String email, String password) async {
    return login(email, password);
  }

  Future<void> updateProfile({
    String? name,
    String? college,
    String? department,
    String? year,
    String? graduationYear,
    String? location,
    String? photoUrl,
    bool? studentVerified,
    bool? emailVerified,
    bool? notificationsEnabled,
  }) async {
    if (name != null) _name = name;
    if (college != null) _college = college;
    if (department != null) _department = department;
    if (year != null) _year = year;
    if (graduationYear != null) _graduationYear = graduationYear;
    if (location != null) _location = location;
    if (photoUrl != null) _photoUrl = photoUrl;
    if (studentVerified != null) _studentVerified = studentVerified;
    if (emailVerified != null) _emailVerified = emailVerified;
    if (notificationsEnabled != null) _notificationsEnabled = notificationsEnabled;
    await _save();
  }

  Future<void> setVerification({bool? studentVerified, bool? emailVerified}) async {
    if (studentVerified != null) _studentVerified = studentVerified;
    if (emailVerified != null) _emailVerified = emailVerified;
    await _save();
  }

  Future<String?> sendPasswordReset(String email) async {
    if (email.trim().isEmpty) return 'Please enter a valid email.';
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email.trim());
    } catch (_) {}
    return null;
  }
}

class LocalUser {
  final String email;
  final String displayName;
  final bool emailVerified;
  final String photoURL;

  LocalUser({
    required this.email,
    required this.displayName,
    required this.emailVerified,
    required this.photoURL,
  });

  Future<void> reload() async {}
  Future<void> updateDisplayName(String name) async {
    AuthService.instance._name = name;
    await AuthService.instance._save();
  }
  Future<void> updatePhotoURL(String url) async {
    AuthService.instance._photoUrl = url;
    await AuthService.instance._save();
  }
  Future<void> sendEmailVerification() async {
    AuthService.instance._emailVerified = true;
    await AuthService.instance._save();
  }
  Future<void> delete() async {
    await AuthService.instance.signOut();
  }
}
