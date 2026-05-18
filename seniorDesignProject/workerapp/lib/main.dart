import 'package:firebase_core/firebase_core.dart';
import 'package:workerapp/routes/app_router.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print("Starting Firebase initialization...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully!");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      title: 'STARX',
      theme: ThemeData(
        fontFamily: "Poppins",
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 145, 114, 240),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(debugShowCheckedModeBanner: false, home: SensorPage());
//   }
// }

// class SensorPage extends StatefulWidget {
//   @override
//   _SensorPageState createState() => _SensorPageState();
// }

// class _SensorPageState extends State<SensorPage> {
//   String data = "Press button to fetch data";

//   // Replace with your ESP32 IP from Serial Monitor
//   final String esp32ip = "http://172.20.10.27/data";

//   Future<void> fetchData() async {
//     try {
//       final response = await http.get(Uri.parse(esp32ip));
//       if (response.statusCode == 200) {
//         var json = jsonDecode(response.body);
//         setState(() {
//           data =
//               "🌡 Temp: ${json['temperature']} °C\n💧 Humidity: ${json['humidity']} %";
//         });
//       } else {
//         setState(() {
//           data = "Error: ${response.statusCode}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         data = "Failed to connect to ESP32";
//       });
//     }
//   }