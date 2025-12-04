import 'package:flutter/material.dart';

class RecordatoriosWidget extends StatelessWidget {
  const RecordatoriosWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final recordatorios = [
      {'titulo': 'Tomar pastilla de la presión', 'hora': '08:00 AM'},
      {'titulo': 'Cita médica con el doctor Pérez', 'hora': '11:30 AM'},
      {'titulo': 'Llamar a Marta', 'hora': '15:00 PM'},
      {'titulo': 'Revisar nivel de glucosa', 'hora': '19:00 PM'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Recordatorios'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recordatorios.length,
        itemBuilder: (context, index) {
          final recordatorio = recordatorios[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.alarm, color: Colors.deepPurple),
              title: Text(recordatorio['titulo']!, style: const TextStyle(fontSize: 18)),
              subtitle: Text('Hora: ${recordatorio['hora']}'),
              trailing: const Icon(Icons.check_circle_outline),
              onTap: () {
                // lógica futura para marcar como completado
              },
            ),
          );
        },
      ),
    );
  }
}