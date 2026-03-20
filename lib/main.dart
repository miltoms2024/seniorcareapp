import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'screens/panel_usuario.dart';
import 'onboarding/onboarding_screen.dart';
import 'screens/editar_perfil_usuario.dart';
import 'screens/perfil_usuario.dart';
import 'onboarding/step_preferences.dart';
import 'package:provider/provider.dart';
import 'onboarding/onboarding_controller.dart';
import 'screens/agregar_medicamento_screen.dart';
import 'screens/lista_medicamentos_screen.dart';

// 🔥 IMPORTANTE: importa AlertasService
import 'services/alertas_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es_ES', null);

  // 🔥 INICIALIZAR NOTIFICACIONES (OBLIGATORIO)
  await AlertasService.inicializar();

  try {
    if (FirebaseAuth.instance.currentUser == null &&
        (kIsWeb || Platform.isAndroid || Platform.isIOS)) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (e) {
    debugPrint('Login anónimo falló: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> verificarUsuarioEnFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error al verificar Firestore: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingController(),
      child: MaterialApp(
        title: 'SeniorCareApp',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 3, 46, 47),
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color.fromARGB(255, 238, 227, 227),
        ),
        debugShowCheckedModeBanner: false,

        home: FutureBuilder<bool>(
          future: verificarUsuarioEnFirestore(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final inicioEnHome = snapshot.data!;
            return inicioEnHome ? const PanelUsuario() : const OnboardingScreen();
          },
        ),

        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => const PanelUsuario(),
          '/editar_perfil': (context) => const EditarPerfilUsuario(),
          '/perfil': (context) => const PerfilUsuario(),
          '/preferencias': (context) => const StepPreferences(),
          '/panel': (context) => const PanelUsuario(),
          '/login': (context) => const OnboardingScreen(),
          '/agregar_medicamento': (context) => const AgregarMedicamentoScreen(),
          '/lista_medicamentos': (context) => const ListaMedicamentosScreen(),
        },
      ),
    );
  }
}