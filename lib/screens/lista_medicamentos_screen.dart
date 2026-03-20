import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/recordatorios_service.dart';
import '../services/alertas_service.dart';

class ListaMedicamentosScreen extends StatelessWidget {
  const ListaMedicamentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicamentos Programados"),
        backgroundColor: Color.fromARGB(255, 218, 237, 230),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamed(context, '/panel_usuario');
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/agregar_medicamento');
        },
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('medicaciones_programadas')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No hay medicamentos registrados",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final med = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(med['nombre_medicina']),
                  subtitle: Text(
                    "Dosis: ${med['dosis']}\n"
                    "Vía: ${med['via']}\n"
                    "Hora: ${med['hora_referencia']}\n"
                    "Cada: ${med['frecuencia_horas']} horas",
                  ),

                  trailing: Switch(
                    value: med['activo'] ?? true,
                    onChanged: (value) async {
                      final idMed = doc.id;
                      final nombre = med['nombre_medicina'];
                      final dosis = med['dosis'];
                      final hora = med['hora_referencia'];

                      // Actualizar estado en Firestore
                      await FirebaseFirestore.instance
                          .collection('medicaciones_programadas')
                          .doc(idMed)
                          .update({'activo': value});

                      // Convertir hora "13:00" a TimeOfDay
                      final partes = hora.split(':');
                      final timeOfDay = TimeOfDay(
                        hour: int.parse(partes[0]),
                        minute: int.parse(partes[1]),
                      );

                      // Por ahora: notificación diaria
                      final dias = [
                        'Lunes',
                        'Martes',
                        'Miércoles',
                        'Jueves',
                        'Viernes',
                        'Sábado',
                        'Domingo'
                      ];

                      if (value == true) {
                        // Crear recordatorio en Firestore
                        await RecordatoriosService.crearRecordatorio(
                          tipo: 'medicacion',
                          titulo: nombre,
                          descripcion: 'Tomar $dosis',
                          hora: hora,
                          dias: dias,
                          activo: true,
                          origen: 'medicacion',
                          idOrigen: idMed,
                        );

                        // Programar notificación
                        await AlertasService.programarNotificacion(
                          idRecordatorio: idMed,
                          titulo: nombre,
                          descripcion: 'Tomar $dosis',
                          hora: timeOfDay,
                          dias: dias,
                        );
                      } else {
                        // Cancelar notificación
                        await AlertasService.cancelarNotificacion(idMed);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}