import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClimaWidget extends StatefulWidget {
  const ClimaWidget({super.key});

  @override
  State<ClimaWidget> createState() => _ClimaWidgetState();
}

class _ClimaWidgetState extends State<ClimaWidget> {
  String climaTexto = 'Cargando clima...';
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    obtenerClima();
  }

  Future<void> obtenerClima() async {
    if (cargando) return;

    setState(() => cargando = true);

    try {
      const latitude = 43.3;
      const longitude = -3.0;

      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&current=temperature_2m,weather_code'
        '&timezone=Europe/Madrid',
      );

      final respuesta = await http.get(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Timeout al conectar con la API'),
      );

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);

        final temp = datos['current']['temperature_2m'];
        final weatherCode = datos['current']['weather_code'];

        final estado = _getWeatherDescription(weatherCode);

        setState(() {
          climaTexto = 'Barakaldo • ${temp.toString()}°C • $estado';
          cargando = false;
        });
      } else {
        setState(() {
          climaTexto = 'Error: ${respuesta.statusCode}';
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        climaTexto = 'Sin conexión';
        cargando = false;
      });
    }
  }

  String _getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Despejado';
      case 1:
      case 2:
        return 'Parcialmente nuboso';
      case 3:
        return 'Nuboso';
      case 45:
      case 48:
        return 'Niebla';
      case 51:
      case 53:
      case 55:
        return 'Llovizna';
      case 61:
      case 63:
      case 65:
        return 'Lluvia';
      case 71:
      case 73:
      case 75:
        return 'Nieve';
      case 77:
        return 'Nieve granulada';
      case 80:
      case 81:
      case 82:
        return 'Lluvia fuerte';
      case 85:
      case 86:
        return 'Nieve con lluvia';
      case 95:
      case 96:
      case 99:
        return 'Tormenta';
      default:
        return 'Desconocido';
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.cloud, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            climaTexto,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: obtenerClima,
              borderRadius: BorderRadius.circular(20),
              child: cargando
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, color: Colors.red, size: 24),
            ),
          ),
        ),
      ],
    );
  }
}
