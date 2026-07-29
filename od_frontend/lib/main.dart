import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OD (Ojek & Delivery)',
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00B14F), // Tema Hijau
          primary: const Color(0xFF00B14F),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // Set halaman utama ke LoginScreen
    );
  }
}
