import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/panel_usuario.dart';
import 'onboarding/onboarding_screen.dart';
import 'screens/editar_perfil_usuario.dart';
import 'screens/perfil_usuario.dart';
import 'onboarding/step_preferences.dart';
import 'package:provider/provider.dart';
import 'onboarding/onboarding_controller.dart';

// NUEVOS FORMULARIOS
import 'screens/agregar_medicamento_largo.dart';
import 'screens/agregar_medicamento_corto.dart';
import 'screens/agregar_medicamento_eventual.dart';

// LISTA UNIFICADA
import 'screens/lista_medicamentos_screen.dart';

import 'services/alertas_service.dart';
import 'package:flutter/services.dart'; // ← NECESARIO PARA BLOQUEAR ORIENTACIÓN
import 'package:firebase_auth/firebase_auth.dart'; // ← NECESARIO PARA AUTH

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔒 BLOQUEAR ORIENTACIÓN SOLO VERTICAL
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es_ES', null);

  // 🔥 LÍNEA QUE FALTABA PARA QUE NO FALLE FIRESTORE
  await FirebaseAuth.instance.signInAnonymously();

  await AlertasService.inicializar();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> verificarRegistroLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('registro_completado') ?? false;
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
          future: verificarRegistroLocal(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final registrado = snapshot.data!;
            return registrado ? const PanelUsuario() : const OnboardingScreen();
          },
        ),

        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => const PanelUsuario(),
          '/editar_perfil': (context) => const EditarPerfilUsuario(),
          '/editarPerfil': (context) => const EditarPerfilUsuario(),

          '/perfil': (context) => const PerfilUsuario(),
          '/preferencias': (context) => const StepPreferences(),
          '/panel': (context) => const PanelUsuario(),
          

          // NUEVAS RUTAS DE MEDICAMENTOS
          '/agregar_medicamento_largo': (context) => AgregarMedicamentoLargoScreen(),
          '/agregar_medicamento_corto': (context) => AgregarMedicamentoCortoScreen(),
          '/agregar_medicamento_eventual': (context) => AgregarMedicamentoEventualScreen(),

          // LISTA UNIFICADA
          '/lista_medicamentos': (context) => const ListaMedicamentosScreen(),
        },
      ),
    );
  }
}
