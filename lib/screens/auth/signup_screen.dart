import 'package:flutter/material.dart';
import 'package:stuentperk_hub/screens/student_verification_screen.dart';
import 'package:stuentperk_hub/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        emailRedirectTo: 'com.studentperkhub.app://login-callback',
        data: {
          'full_name': nameController.text.trim(),
          'mobile': mobileController.text.trim(),
        },
      );

      if (!mounted) return;

      if (response.user != null) {
        await AuthService.instance.updateProfile(
          name: nameController.text.trim(),
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentVerificationScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
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
                  const SizedBox(height: 25),
                  IconButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF172554),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B5FEF),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                            const Color(0xFF5B5FEF).withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Center(
                    child: Text(
                      'Create Account',
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
                      'Join StudentPerk Hub',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  const Text(
                    'Full Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
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
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 3) {
                        return 'Name must contain at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Mobile Number',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'Enter your mobile number',
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
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
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      if (value.length != 10) {
                        return 'Enter a valid 10-digit number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
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
                      hintText: 'Enter your email address',
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
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
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
                      hintText: 'Create a password',
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
                        return 'Please create a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Confirm Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !isConfirmPasswordVisible,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'Confirm your password',
                      prefixIcon: const Icon(
                        Icons.lock_reset_outlined,
                        color: Color(0xFF64748B),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isConfirmPasswordVisible =
                            !isConfirmPasswordVisible;
                          });
                        },
                        icon: Icon(
                          isConfirmPasswordVisible
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
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : createAccount,
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
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: isLoading ? null : goToLogin,
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF5B5FEF),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
