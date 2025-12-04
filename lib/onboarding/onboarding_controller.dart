import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingController extends ChangeNotifier {
  String nombre = "";
  String edad = "";
  String genero = "";
  String desayuno = "";
  String almuerzo = "";
  String cena = "";
  List<String> actividades = [];
  String energia = "";

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
  }) {
    this.desayuno = desayuno;
    this.almuerzo = almuerzo;
    this.cena = cena;
    notifyListeners();
  }

  void actualizarPreferencias({
    required List<String> actividades,
    required String energia,
  }) {
    this.actividades = actividades;
    this.energia = energia;
    notifyListeners();
  }

  Future<void> guardarEnFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("No se pudo obtener el UID del usuario.");
    }

    final docRef = FirebaseFirestore.instance.collection('usuarios').doc(uid);

    await docRef.set({
      'nombre': nombre,
      'edad': edad,
      'genero': genero,
      'desayuno': desayuno,
      'almuerzo': almuerzo,
      'cena': cena,
      'actividades': actividades,
      'energia': energia,
    }, SetOptions(merge: true));
  }
}