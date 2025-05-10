import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase'i başlatmak için import
import 'screens/main_tab_screen.dart'; // Ekranınızı import ediyoruz

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Firebase'i başlatmadan önce bu fonksiyonu çağırmalıyız.


  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Game Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainTabScreen(),
    );
  }
}
