import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:stuentperk_hub/bottom_navigation/home_screen.dart';

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

class _EmailVerificationScreenState
    extends State<EmailVerificationScreen> {

  final List<TextEditingController> otpControllers =
      List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> focusNodes =
      List.generate(
    6,
    (index) => FocusNode(),
  );

  bool isSendingOtp = false;
  bool isVerifyingOtp = false;
  bool otpSent = false;

  int secondsRemaining = 0;

  Timer? timer;

  FirebaseFunctions get functions =>
      FirebaseFunctions.instance;


  @override
  void dispose() {

    timer?.cancel();

    for (final controller in otpControllers) {
      controller.dispose();
    }

    for (final node in focusNodes) {
      node.dispose();
    }

    super.dispose();
  }


  // ============================================================
  // SEND OTP
  // ============================================================

  Future<void> sendOTP() async {

    if (isSendingOtp) {
      return;
    }

    setState(() {
      isSendingOtp = true;
    });

    try {

      final HttpsCallable callable =
          functions.httpsCallable(
        'sendEmailOtp',
      );

      await callable.call({
        'email': widget.email.trim(),
      });

      if (!mounted) {
        return;
      }

      setState(() {
        isSendingOtp = false;
        otpSent = true;
        secondsRemaining = 60;
      });

      startCountdown();

      clearOTP();

      FocusScope.of(context).requestFocus(
        focusNodes[0],
      );

      showMessage(
        'OTP sent to ${widget.email}',
      );

    } on FirebaseFunctionsException catch (e) {

      if (!mounted) {
        return;
      }

      setState(() {
        isSendingOtp = false;
      });

      showMessage(
        e.message ?? 'Unable to send OTP.',
        isError: true,
      );

    } catch (e) {

      if (!mounted) {
        return;
      }

      setState(() {
        isSendingOtp = false;
      });

      showMessage(
        'Something went wrong. Please try again.',
        isError: true,
      );
    }
  }


  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<void> verifyOTP() async {

    final otp = otpControllers
        .map((controller) => controller.text)
        .join();

    if (otp.length != 6) {

      showMessage(
        'Please enter the 6-digit OTP.',
        isError: true,
      );

      return;
    }

    if (isVerifyingOtp) {
      return;
    }

    setState(() {
      isVerifyingOtp = true;
    });

    try {

      final HttpsCallable callable =
          functions.httpsCallable(
        'verifyEmailOtp',
      );

      await callable.call({
        'otp': otp,
      });

      if (!mounted) {
        return;
      }

      setState(() {
        isVerifyingOtp = false;
      });

      await showSuccessDialog();

    } on FirebaseFunctionsException catch (e) {

      if (!mounted) {
        return;
      }

      setState(() {
        isVerifyingOtp = false;
      });

      String message =
          e.message ?? 'Unable to verify OTP.';

      if (e.code == 'deadline-exceeded') {
        message =
            'OTP expired. Please request a new OTP.';
      } else if (e.code == 'invalid-argument') {
        message = 'Incorrect OTP. Please try again.';
      } else if (e.code == 'resource-exhausted') {
        message =
            'Too many incorrect attempts. Please request a new OTP.';
      } else if (e.code == 'not-found') {
        message =
            'OTP not found. Please request a new OTP.';
      } else if (e.code == 'unauthenticated') {
        message =
            'Your session expired. Please log in again.';
      }

      showMessage(
        message,
        isError: true,
      );

    } catch (e) {

      if (!mounted) {
        return;
      }

      setState(() {
        isVerifyingOtp = false;
      });

      showMessage(
        'Something went wrong. Please try again.',
        isError: true,
      );
    }
  }


  // ============================================================
  // OTP BOX INPUT
  // ============================================================

  void handleOTPInput(
    int index,
    String value,
  ) {

    if (value.isNotEmpty && index < 5) {

      FocusScope.of(context).requestFocus(
        focusNodes[index + 1],
      );

    } else if (
        value.isEmpty &&
        index > 0
    ) {

      FocusScope.of(context).requestFocus(
        focusNodes[index - 1],
      );
    }

    setState(() {});
  }


  // ============================================================
  // CLEAR OTP
  // ============================================================

  void clearOTP() {

    for (final controller in otpControllers) {
      controller.clear();
    }

    setState(() {});
  }


  // ============================================================
  // COUNTDOWN
  // ============================================================

  void startCountdown() {

    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {

        if (secondsRemaining <= 1) {

          timer.cancel();

          if (mounted) {
            setState(() {
              secondsRemaining = 0;
            });
          }

        } else {

          if (mounted) {
            setState(() {
              secondsRemaining--;
            });
          }
        }
      },
    );
  }


  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  Future<void> showSuccessDialog() async {

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Row(
            children: [
              Icon(
                Icons.verified_rounded,
                color: Colors.green,
                size: 30,
              ),

              SizedBox(width: 10),

              Text('Email Verified'),
            ],
          ),

          content: const Text(
            'Your email has been successfully verified.',
          ),

          actions: [

            TextButton(
              onPressed: () {

                Navigator.of(context).pop();

              },

              child: const Text(
                'Continue',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (context) =>
            const HomeScreen(),
      ),

      (route) => false,
    );
  }


  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(
    String message, {
    bool isError = false,
  }) {

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),

          backgroundColor:
              isError ? Colors.red : Colors.green,

          behavior:
              SnackBarBehavior.floating,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }


  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF8F7FF),

      appBar: AppBar(

        backgroundColor:
            Colors.transparent,

        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF17152B),
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.center,

            children: [

              const SizedBox(height: 25),

              // EMAIL ICON

              Container(
                width: 90,
                height: 90,

                decoration: BoxDecoration(
                  color: const Color(0xFFEAE7FF),

                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.mark_email_read_rounded,

                  size: 45,

                  color: Color(0xFF6C63FF),
                ),
              ),

              const SizedBox(height: 25),

              // TITLE

              const Text(
                'Verify Your Email',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17152B),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'We will send a 6-digit verification code to',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                widget.email,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C63FF),
                ),
              ),

              const SizedBox(height: 35),


              // SEND OTP BUTTON

              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton(

                  onPressed:
                      isSendingOtp
                          ? null
                          : sendOTP,

                  style: ElevatedButton.styleFrom(

                    backgroundColor:
                        const Color(0xFF6C63FF),

                    disabledBackgroundColor:
                        Colors.grey.shade400,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),

                  child: isSendingOtp

                      ? const SizedBox(
                          width: 22,
                          height: 22,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )

                      : Text(
                          otpSent
                              ? 'Resend OTP'
                              : 'Send OTP',

                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),


              const SizedBox(height: 30),


              // OTP SECTION

              if (otpSent) ...[

                Text(
                  'Enter the verification code',

                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: List.generate(
                    6,
                    (index) {

                      return SizedBox(
                        width: 45,
                        height: 55,

                        child: TextField(

                          controller:
                              otpControllers[index],

                          focusNode:
                              focusNodes[index],

                          keyboardType:
                              TextInputType.number,

                          textAlign:
                              TextAlign.center,

                          maxLength: 1,

                          style:
                              const TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),

                          decoration:
                              InputDecoration(

                            counterText: '',

                            filled: true,

                            fillColor:
                                Colors.white,

                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),

                              borderSide:
                                  BorderSide(
                                color:
                                    Colors.grey.shade300,
                              ),
                            ),

                            focusedBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),

                              borderSide:
                                  const BorderSide(
                                color:
                                    Color(0xFF6C63FF),
                                width: 2,
                              ),
                            ),
                          ),

                          onChanged: (value) {
                            handleOTPInput(
                              index,
                              value,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),


                // VERIFY BUTTON

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton(

                    onPressed:
                        isVerifyingOtp
                            ? null
                            : verifyOTP,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF17152B),

                      disabledBackgroundColor:
                          Colors.grey.shade400,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),

                    child:
                        isVerifyingOtp

                            ? const SizedBox(
                                width: 22,
                                height: 22,

                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Colors.white,
                                ),
                              )

                            : const Text(
                                'Verify OTP',

                                style:
                                    TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      Colors.white,
                                ),
                              ),
                  ),
                ),


                const SizedBox(height: 18),


                // RESEND TIMER

                if (secondsRemaining > 0)

                  Text(
                    'Resend OTP in ${secondsRemaining}s',

                    style: TextStyle(
                      color:
                          Colors.grey.shade600,
                    ),
                  )

                else

                  TextButton(
                    onPressed: sendOTP,

                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(
                        color:
                            Color(0xFF6C63FF),
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
              ],


              const SizedBox(height: 35),


              // SECURITY MESSAGE

              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color:
                      const Color(0xFFF0EEFF),

                  borderRadius:
                      BorderRadius.circular(14),
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Icon(
                      Icons.lock_outline_rounded,

                      color:
                          Color(0xFF6C63FF),

                      size: 22,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'Your verification code is valid for 5 minutes. Never share your OTP with anyone.',

                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color:
                              Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}