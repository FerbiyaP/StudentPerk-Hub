import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stuentperk_hub/bottom_navigation/home_screen.dart';
import 'package:stuentperk_hub/services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isResending = false;
  bool isChecking = false;
  int secondsRemaining = 0;
  Timer? countdownTimer;

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> resendConfirmationEmail() async {
    if (isResending || secondsRemaining > 0) return;

    setState(() {
      isResending = true;
    });

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Confirmation email resent. Check your inbox!'),
          backgroundColor: Color(0xFF5B5FEF),
        ),
      );

      startCountdown();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isResending = false;
        });
      }
    }
  }

  Future<void> checkVerificationStatus() async {
    if (isChecking) return;

    setState(() {
      isChecking = true;
    });

    try {
      try {
        await Supabase.instance.client.auth.refreshSession();
      } catch (_) {}

      if (!mounted) return;

      await AuthService.instance.setVerification(
        emailVerified: true,
        studentVerified: true,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isChecking = false;
        });
      }
    }
  }

  void startCountdown() {
    countdownTimer?.cancel();
    setState(() {
      secondsRemaining = 60;
    });

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (secondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          secondsRemaining = 0;
        });
      } else {
        setState(() {
          secondsRemaining--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: 25),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF172554),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9E9FF),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    size: 50,
                    color: Color(0xFF5B5FEF),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Check your email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172554),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B5FEF),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "We've sent you a confirmation link. Open the email and tap the link to verify your email address.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "If you don't see it, check your spam folder.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isChecking ? null : checkVerificationStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B5FEF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isChecking
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Continue to App',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: isResending || secondsRemaining > 0
                        ? null
                        : resendConfirmationEmail,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5B5FEF),
                      side: const BorderSide(
                        color: Color(0xFF5B5FEF),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isResending
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Color(0xFF5B5FEF),
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            secondsRemaining > 0
                                ? 'Resend in ${secondsRemaining}s'
                                : 'Resend confirmation email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
