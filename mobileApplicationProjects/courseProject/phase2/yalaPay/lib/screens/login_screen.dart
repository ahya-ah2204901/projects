import 'package:firebase_auth/firebase_auth.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/method_constants.dart';
import 'package:yala_pay/providers/user_provider.dart';
import '../routes/app_router.dart';

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
    var screenSize = MediaQuery.of(context).size;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final iconTopPosition =
        isKeyboardOpen ? screenSize.width * 0.3 : screenSize.width * 0.6;

    final usersProvider = ref.watch(userNotifierProvider);

    return Scaffold(
      backgroundColor: accentColor,
      body: Stack(alignment: Alignment.center, children: [
        Positioned(
          top: iconTopPosition + 45,
          child: SizedBox(
            width: screenSize.width * 0.74,
            height: 340,
            child: Card(
              elevation: 15,
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 15.0, right: 20, left: 20, top: 65),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EMAIL:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color.fromARGB(255, 8, 40, 65),
                        letterSpacing: 1.1,
                      ),
                    ),
                    TextField(
                        style: const TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 56, 56, 56)),
                        decoration: const InputDecoration(
                          labelText: (' abc@yalapay.com'),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelStyle: TextStyle(
                            fontSize: 15,
                          ),
                          fillColor: Color.fromARGB(151, 151, 151, 151),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40))),
                        ),
                        onChanged: (value) => email = value),
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: Text(
                        'PASSWORD:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color.fromARGB(255, 8, 40, 65),
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    TextField(
                        onChanged: (value) => password = value,
                        obscureText: true,
                        style: const TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 105, 105, 105)),
                        decoration: const InputDecoration(
                          labelText: (' •••••••••'),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelStyle: TextStyle(fontSize: 15),
                          fillColor: Color.fromARGB(68, 227, 227, 227),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40))),
                        )),
                    const Spacer(),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15),
                        child: Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: secondaryColor,
                                  elevation: 3,
                                  fixedSize: Size(screenSize.width * 0.25,
                                      screenSize.height * 0.06),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              onPressed: () =>
                                  context.goNamed(AppRouter.signup.name),
                              child: const Text(
                                "SIGN UP",
                                style: TextStyle(
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.5,
                                    color: Colors.white),
                              ),
                            ),
                            Spacer(),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  elevation: 3,
                                  fixedSize: Size(screenSize.width * 0.25,
                                      screenSize.height * 0.06),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              onPressed: () async {
                                if (email.trim().isEmpty ||
                                    password.trim().isEmpty) {
                                  snackbarError(context, 'Fill all Fields.');
                                } else {
                                  User? user = await ref
                                      .read(userNotifierProvider.notifier)
                                      .signIn(email: email, password: password);

                                  (user != null)
                                      ? context
                                          .goNamed(AppRouter.dashboard.name)
                                      : snackbarError(context,
                                          'Email or Password is Incorrect');
                                }
                              },
                              child: const Text(
                                "LOGIN",
                                style: TextStyle(
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.5,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: iconTopPosition - 130,
          child: Image.asset(
            'assets/images/YalaPay_icon.png',
            height: 80,
          ),
        ),
        Positioned(
          top: iconTopPosition,
          child: Image.asset(
            'assets/images/YalaPay_title.png',
            height: screenSize.width * 0.28,
            alignment: const Alignment(0, 0),
          ),
        ),
      ]),
    );
  }
}
