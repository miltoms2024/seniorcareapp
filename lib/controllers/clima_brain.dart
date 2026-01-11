import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClimaBrain extends ChangeNotifier {
  Map<String, dynamic>? clima;

  Future<void> cargarClima(String ciudad) async {
    final url = Uri.parse(
      "https://api.open-meteo.com/v1/forecast?latitude=43.297&longitude=-2.986&current_weather=true"
    );

    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      clima = json.decode(resp.body);
      notifyListeners();
    }
  }

  String get temperatura {
    if (clima == null) return "--°";
    return "${clima!['current_weather']['temperature']}°";
  }

  String get estado {
    if (clima == null) return "Cargando...";
    return "Clima actual";
  }
}