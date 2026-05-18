import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workerapp/models/user.dart';
import 'package:workerapp/providers/auth_provider.dart';
import 'package:workerapp/providers/user_provider.dart';
import 'package:workerapp/routes/app_router.dart';
import 'package:workerapp/widgets/snackbar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      snackbarError(context, 'Please fill in all fields.');
      return;
    }

    final user = await ref
        .read(authNotifierProvider.notifier)
        .signIn(email: email, password: password);

    if (!mounted) return;

    // if (user != null) {
    //   final List<User>? users = ref.watch(userNotifierProvider).value;
    //   final User loggedInUser = users!.firstWhere((u) => u.id == user.uid);

    //   if (loggedInUser.role == "Worker") {
    //     context.goNamed(AppRouter.worker_home.name);
    //   } else if (loggedInUser.role == "Supervisor") {
    //     context.goNamed(AppRouter.supervisor_home.name);
    //   }
    // }

    if (user != null) {
      await user.reload();
      // final refreshedUser = fb.FirebaseAuth.instance.currentUser;

      // if (refreshedUser != null && !refreshedUser.emailVerified) {
      //   await fb.FirebaseAuth.instance.signOut();
      //   snackbarError(context, 'Please verify your email before logging in.');
      //   return;
      // }

      final List<User>? users = ref.watch(userNotifierProvider).value;
      final User loggedInUser = users!.firstWhere((u) => u.id == user.uid);

      if (loggedInUser.role == "Worker") {
        context.goNamed(AppRouter.workerHome.name);
      } else if (loggedInUser.role == "Supervisor") {
        context.goNamed(AppRouter.supervisorHome.name);
      }
    } else {
      snackbarError(context, 'Email or password is incorrect.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersProvider = ref.watch(userNotifierProvider);
    final authProvider = ref.watch(authNotifierProvider);
    final userNotifier = ref.read(userNotifierProvider.notifier);
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), //const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 60,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 320,
                        height: 110,
                        padding: const EdgeInsets.all(8),

                        child: ClipRRect(
                          //borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            'assets/images/title.jpeg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF001B57),
                  ),
                ),
                const SizedBox(height: 36),

                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF001B57),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email address',
                    hintStyle: const TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFEAEAF0),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: const BorderSide(
                        color: Color(0xFF001B57),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF001B57),
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                    hintStyle: const TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFEAEAF0),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: const BorderSide(
                        color: Color(0xFF001B57),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF001B57),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      final email = emailController.text.trim();

                      if (email.isEmpty) {
                        snackbarError(context, 'Enter your email first.');
                        return;
                      }

                      await ref
                          .read(authNotifierProvider.notifier)
                          .resetPassword(email: email);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password reset email sent.'),
                        ),
                      );
                    },

                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Forgot your password?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8F8F8F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7A5A45),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.goNamed(AppRouter.signup.name);
                        },
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF3C39D0),
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
