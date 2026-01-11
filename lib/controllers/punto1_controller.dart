import 'dart:async';
import 'package:flutter/material.dart';

class Punto1Controller {
  static final Punto1Controller _instancia = Punto1Controller._interno();
  factory Punto1Controller() => _instancia;
  Punto1Controller._interno();

  bool _modalMostrado = false;

  // ✅ Iniciar flujo para cualquier rutina esencial
  void iniciarFlujo({
    required BuildContext context,
    required String rutina, // desayuno, almuerzo, cena, dormir, despertar
  }) {
    if (_modalMostrado) return;

    // ✅ Dormir → NO usar retraso (se pregunta ANTES)
    if (rutina == "dormir") {
      _mostrarModal(context, rutina);
      return;
    }

    // ✅ Despertar y comidas → usar retraso
    Timer(const Duration(minutes: 30), () {
      if (!_modalMostrado) {
        _mostrarModal(context, rutina);
      }
    });
  }

  // ✅ Modal obligatorio
  void _mostrarModal(BuildContext context, String rutina) {
    _modalMostrado = true;

    final titulo = _tituloPara(rutina);
    final opciones = _opcionesPara(rutina);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: const Text("Selecciona una opción para continuar."),
          actions: opciones.map((opcion) {
            return TextButton(
              onPressed: () {
                _guardarRespuesta(rutina, opcion["valor"]!);
                Navigator.pop(context);
              },
              child: Text(opcion["texto"]!),
            );
          }).toList(),
        );
      },
    );
  }

  // ✅ Títulos dinámicos
  String _tituloPara(String rutina) {
    switch (rutina) {
      case "dormir":
        return "¿Cómo te sientes antes de dormir?";
      case "despertar":
        return "¿Cómo amaneciste?";
      default:
        return "¿Qué tal el $rutina?";
    }
  }

  // ✅ Opciones dinámicas
  List<Map<String, String>> _opcionesPara(String rutina) {
    if (rutina == "dormir") {
      return [
        {"texto": "Listo para dormir", "valor": "listo"},
        {"texto": "Un poco inquieto", "valor": "inquieto"},
        {"texto": "Me siento mal", "valor": "mal"},
      ];
    }

    if (rutina == "despertar") {
      return [
        {"texto": "Amanecí bien", "valor": "bien"},
        {"texto": "Amanecí cansado", "valor": "cansado"},
        {"texto": "Amanecí mal", "valor": "mal"},
      ];
    }

    // ✅ Comidas
    return [
      {"texto": "Estuvo bien", "valor": "bien"},
      {"texto": "Pudo estar mejor", "valor": "mejor"},
      {"texto": "No comí", "valor": "no_comio"},
    ];
  }

  // ✅ Registro de respuesta
  void _guardarRespuesta(String rutina, String respuesta) {
    print("Respuesta registrada: $rutina → $respuesta");
    _modalMostrado = false;
  }
}