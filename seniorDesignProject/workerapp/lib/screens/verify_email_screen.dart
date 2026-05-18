import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workerapp/providers/auth_provider.dart';
import 'package:workerapp/routes/app_router.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  Future<void> _checkVerification(BuildContext context) async {
    final isVerified = await ref
        .read(authNotifierProvider.notifier)
        .checkEmailVerificationAndSignOut();

    if (isVerified) {
      if (context.mounted) context.goNamed(AppRouter.login.name);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your email first.')),
      );
    }
  }

  Future<void> _resendEmail(BuildContext context) async {
    await ref.read(authNotifierProvider.notifier).resendVerificationEmail();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email resent.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: Color(0xFFE8EEF9),
                    child: Icon(
                      Icons.mark_email_unread_outlined,
                      size: 42,
                      color: Color(0xFF001B57),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Verify your email',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF001B57),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We sent a verification email to your inbox. Please verify your email before logging in.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _checkVerification(context),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('I verified my email'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF001B57),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _resendEmail(context),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Resend verification email'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF001B57),
                        side: const BorderSide(color: Color(0xFF001B57)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () async {
                      await ref.read(authNotifierProvider.notifier).signOut();
                      if (context.mounted) {
                        context.goNamed(AppRouter.login.name);
                      }
                    },
                    child: const Text(
                      'Back to login',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
