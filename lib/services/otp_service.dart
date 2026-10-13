import 'package:supabase_flutter/supabase_flutter.dart';

class OtpService {
  static final supabase = Supabase.instance.client;

  static Future<Map<String, dynamic>> sendOTP(String email) async {
    try {
      await supabase.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
      );
      return {'success': true, 'message': 'Verification code sent successfully.'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> verifyOTP(
      String email,
      String code,
      ) async {
    try {
      await supabase.auth.verifyOTP(
        type: OtpType.signup,
        email: email.trim(),
        token: code.trim(),
      );
      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
