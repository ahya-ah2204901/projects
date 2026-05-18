import 'package:accelaid/models/color_const.dart';
import 'package:accelaid/routes/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully!");
  } catch (e) { 
    print("Firebase initialization failed: $e");
  }
  await dotenv.load(fileName: "assets/.env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      title: 'AccelAid',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: lightblue),
        useMaterial3: true,
      ),
    );
  }
}
