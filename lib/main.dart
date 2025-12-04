import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (e) {
    debugPrint('Login anónimo falló: $e');
  }

  final bool inicioEnHome = await verificarUsuarioEnFirestore();
  runApp(MyApp(inicioEnHome: inicioEnHome));
}

Future<bool> verificarUsuarioEnFirestore() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return false;

  try {
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    return doc.exists;
  } catch (e) {
    debugPrint('Error al verificar Firestore: $e');
    return false;
  }
}

class MyApp extends StatelessWidget {
  final bool inicioEnHome;
  const MyApp({super.key, required this.inicioEnHome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeniorCareApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      initialRoute: inicioEnHome ? '/home' : '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}