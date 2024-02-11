import 'package:check_yourself/views/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check Yourself',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          canvasColor: Colors.yellow.shade100,
          snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.deepPurple,
            actionTextColor: Colors.white,
          )),
      home: const MyHomePage(),
    );
  }
}
