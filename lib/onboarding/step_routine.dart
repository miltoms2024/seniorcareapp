import 'package:flutter/material.dart';

class StepRoutine extends StatelessWidget {
  const StepRoutine({super.key});

  @override
  Widget build(BuildContext context) {
    final rutinas = [
      {'titulo': 'Caminar 30 minutos', 'hora': '10:00 AM'},
      {'titulo': 'Ejercicios de estiramiento', 'hora': '12:00 PM'},
      {'titulo': 'Leer un capítulo de un libro', 'hora': '16:00 PM'},
      {'titulo': 'Llamar a un ser querido', 'hora': '18:00 PM'},
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 217, 217),
      appBar: AppBar(
        title: const Text('Rutinas del día'),
        backgroundColor: const Color.fromARGB(255, 218, 225, 218),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rutinas.length,
        itemBuilder: (context, index) {
          final rutina = rutinas[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.access_time, color: Color.fromARGB(255, 188, 175, 184)),
              title: Text(rutina['titulo']!, style: const TextStyle(fontSize: 18)),
              subtitle: Text('Horario sugerido: ${rutina['hora']}'),
              trailing: const Icon(Icons.check_circle_outline),
              onTap: () {
                // lógica futura para marcar como completada
              },
            ),
          );
        },
      ),
    );
  }
}