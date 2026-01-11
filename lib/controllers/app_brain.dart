import 'dart:async';
import 'package:flutter/material.dart';

class AppBrain extends ChangeNotifier {
  Map<String, dynamic>? usuario;
  TimeOfDay ahora = TimeOfDay.now();
  Timer? _timer;

  AppBrain() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      tickHora();
    });
  }

  void setUsuario(Map<String, dynamic> data) {
    usuario = data;
    notifyListeners();
  }

  void tickHora() {
    ahora = TimeOfDay.now();
    notifyListeners();
  }

  bool esHora(String hora) {
    if (usuario == null) return false;
    final partes = hora.split(':');
    final h = int.parse(partes[0]);
    final m = int.parse(partes[1]);
    return ahora.hour == h && ahora.minute == m;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}