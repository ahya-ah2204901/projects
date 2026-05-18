import 'package:firebase_auth/firebase_auth.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/method_constants.dart';
import 'package:yala_pay/providers/user_provider.dart';
import '../routes/app_router.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

var errorController = TextEditingController(text: '');
String email = '', password = '', fullname = '', passwordconfirm = '';

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  void dispose() {
    email = '';
    password = '';
    fullname = '';
    passwordconfirm = '';
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
            height: 500,
            child: Card(
              elevation: 15,
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 15.0, right: 20, left: 20, top: 45),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        '      CREATE AN ACCOUNT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: secondaryColor,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const Text(
                      'FULL NAME:',
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
                          labelText: (' Full Name'),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelStyle: TextStyle(
                            fontSize: 15,
                          ),
                          fillColor: Color.fromARGB(151, 151, 151, 151),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40))),
                        ),
                        onChanged: (value) => fullname = value),
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'EMAIL:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color.fromARGB(255, 8, 40, 65),
                          letterSpacing: 1.1,
                        ),
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
                      padding: EdgeInsets.only(top: 8.0),
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
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'CONFIRM PASSWORD:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color.fromARGB(255, 8, 40, 65),
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    TextField(
                        onChanged: (value) => passwordconfirm = value,
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
                                  context.goNamed(AppRouter.login.name),
                              child: const Text(
                                "RETURN",
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
                                if (isValidRegistration(
                                    email, password, passwordconfirm)) {
                                 
                                  User? user = await ref
                                      .read(userNotifierProvider.notifier)
                                      .signUp(
                                          email: email,
                                          password: password,
                                          fullName: fullname);

                                  if (user != null) {
                                    context.goNamed(AppRouter.dashboard.name);
                                  }
                                }
                              },
                              child: const Text(
                                "SIGN UP",
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

  bool isValidEmail(String email) {
    return email.endsWith('@yalapay.com') && email.length > 12;
  }

  bool isValidPassword(String password) {
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    return password.length >= 6 && hasLetters && hasNumbers;
  }

  bool isValidRegistration(String email, password, passwordconfirm) {
    bool isValidEm;
    bool isValidPass;
    if (email.trim().isEmpty ||
        password.trim().isEmpty ||
        passwordconfirm.trim().isEmpty ||
        fullname.trim().isEmpty) {
      snackbarError(context, 'Fill all Fields.');
      return false;
    } else {
      isValidEm = isValidEmail(email);
      isValidPass = isValidPassword(password);
      if (password != passwordconfirm) {
        snackbarError(context, 'Passwords do no match.');
        return false;
      } else if (!isValidEm && !isValidPass) {
        snackbarError(context,
            'Invalid Email and Password. \nMust be atleast 6 alphanumerical characters.');
        return false;
      } else if (!isValidEm || !isValidPass) {
        snackbarError(
            context,
            (!isValidEm)
                ? 'Invalid Email'
                : 'Invalid Password.\nMust be atleast 6 alphanumerical characters.');
        return false;
      } else {
        return true;
      }
    }
  }
}
