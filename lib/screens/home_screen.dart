import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'clima_widget.dart';
import 'time_widget.dart';
import 'agregar_medicamento_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void eliminarMedicamento(String id, BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar medicamento?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('medicamentos').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Panel de cuidados'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TimeWidget(),
            const SizedBox(height: 12),
            const ClimaWidget(),
            const SizedBox(height: 24),
            const Text(
              'Medicamentos programados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('medicamentos')
                    .orderBy('hora')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No hay medicamentos registrados'),
                    );
                  }

                  final medicamentos = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: medicamentos.length,
                    itemBuilder: (context, index) {
                      final med = medicamentos[index];
                      return ListTile(
                        title: Text(med['nombre']),
                        subtitle: Text('Hora: ${med['hora']} • Frecuencia: ${med['frecuencia']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => eliminarMedicamento(med.id, context),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgregarMedicamentoScreen()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}