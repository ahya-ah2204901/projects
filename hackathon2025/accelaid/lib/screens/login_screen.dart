import 'package:accelaid/models/color_const.dart';
import 'package:accelaid/providers/teacher_provider.dart';
import 'package:accelaid/providers/user_provider.dart';
import 'package:accelaid/routes/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

var errorController = TextEditingController(text: '');
String email = '', password = '';

class _LoginScreenState extends ConsumerState<LoginScreen> {
  void dispose() {
    email = '';
    password = '';
    errorController.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(alignment: AlignmentDirectional.centerStart, children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/layout/login_bg.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
            bottom: 6,
            right: 130,
            child: Text(
              'AccelAid.',
              style: TextStyle(
                  fontSize: 30,
                  color: lightblue,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0),
            )),
        Positioned(
          right: 60,
          top: 270,
          child: SizedBox(
              width: 290,
              height: 415,
              child: Card(
                elevation: 15,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: darkblue,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'EMAIL:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: darkblue,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.email, color: darkblue),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) => email = value,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'PASSWORD:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: darkblue,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        onChanged: (value) => password = value,
                        obscureText: true,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          prefixIcon: Icon(Icons.lock, color: darkblue),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkred,
                            elevation: 5,
                            fixedSize: const Size(120, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (email.trim().isEmpty || password.isEmpty) {
                              snackbarError(
                                  context, 'Fill all Fields.', darkred);
                            } else {
                              User? user = await ref
                                  .read(userNotifierProvider.notifier)
                                  .signIn(
                                      email: email.trim(),
                                      password: password.trim());

                              if (user != null) {
                                context.goNamed(AppRouter.dashboard.name);
                              } else {
                                snackbarError(context,
                                    'Email or Password is Incorrect', darkred);
                              }
                            }
                          },
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Spacer(),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: darkblue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ]),
    );
  }
}
