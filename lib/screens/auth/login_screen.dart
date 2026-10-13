import 'package:flutter/material.dart';
import 'package:stuentperk_hub/screens/auth/signup_screen.dart';
import 'package:stuentperk_hub/screens/student_verification_screen.dart';
import 'package:stuentperk_hub/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final error = await AuthService.instance.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (error != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Color(0xFF5B5FEF),
          duration: Duration(seconds: 1),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const StudentVerificationScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address first.'),
        ),
      );
      return;
    }

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.studentperkhub.app://login-callback',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'If this email is registered, a password reset email may arrive shortly. Check your inbox and spam folder.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset failed: $e')),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final error = await AuthService.instance.signInWithGoogle();
      if (error != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> googleLogin() async {
    await signInWithGoogle();
  }

  void signUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Center(
                    child: Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B5FEF),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5B5FEF).withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Center(
                    child: Text(
                      'StudentPerk Hub',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172554),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Login to continue',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172554),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFF64748B),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF5B5FEF),
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xFF64748B),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF5B5FEF),
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading ? null : resetPassword,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF5B5FEF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B5FEF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : googleLogin,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade100,
                            ),
                            child: const Center(
                              child: Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4285F4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: isLoading ? null : signUp,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color(0xFF5B5FEF),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
