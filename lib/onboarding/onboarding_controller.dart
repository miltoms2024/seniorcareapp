import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends ChangeNotifier {
  String nombre = "";
  String edad = "";
  String genero = "";

  String desayuno = "";
  String almuerzo = "";
  String cena = "";
  bool siesta = false;

  String dormir = "22:15–06:00";

  String actividad = "";
  String energia = "";

  void actualizarSiesta(bool valor) {
    siesta = valor;
    notifyListeners();
  }

  void actualizarIdentidad({
    required String nombre,
    required String edad,
    required String genero,
  }) {
    this.nombre = nombre;
    this.edad = edad;
    this.genero = genero;
    notifyListeners();
  }

  void actualizarRutina({
    required String desayuno,
    required String almuerzo,
    required String cena,
    required String dormir,
  }) {
    this.desayuno = desayuno;
    this.almuerzo = almuerzo;
    this.cena = cena;
    this.dormir = dormir;
    notifyListeners();
  }

  void actualizarPreferencias({
    required List<String> actividades,
    required String energia,
  }) {
    if (actividades.isNotEmpty) {
      actividad = actividades.first;
    }
    this.energia = energia;
    notifyListeners();
  }

  /// Guarda los datos en Firestore y marca el onboarding como completado
  /// en SharedPreferences para que `main.dart` muestre el panel en adelante.
  Future<void> guardarEnFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return Future.error("No se pudo obtener el UID del usuario.");
      }

      final uid = user.uid;
      final docRef = FirebaseFirestore.instance.collection('usuarios').doc(uid);

      await docRef.set({
        'nombre': nombre,
        'edad': edad,
        'genero': genero,
        'desayuno': desayuno,
        'almuerzo': almuerzo,
        'cena': cena,
        'siesta': siesta,
        'dormir': dormir,
        'actividad': actividad,
        'energia': energia,
      }, SetOptions(merge: true));

      // Marcar onboarding completado localmente para que main.dart muestre PanelUsuario
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('registro_completado', true);
      await prefs.setString('userId', uid);

    } catch (e) {
      // Re-lanzar el error para que la UI lo maneje si es necesario
      return Future.error("Error al guardar en Firestore: $e");
    }
  }
}
