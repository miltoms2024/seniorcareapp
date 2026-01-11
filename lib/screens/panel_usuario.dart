import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'clima_widget.dart';
import 'time_widget.dart';
import '../controllers/app_brain.dart';
import 'package:provider/provider.dart';

class PanelUsuario extends StatelessWidget {
  const PanelUsuario({super.key});

  Future<Map<String, dynamic>?> cargarDatosUsuario() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();

    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppBrain(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 238, 235, 235),
            appBar: AppBar(
              title: const Text('SeniorCare – te acompaña en tu día a día'),
              backgroundColor: const Color.fromARGB(255, 218, 237, 230),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clima + Hora
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ClimaWidget(),
                      SizedBox(height: 8),
                      TimeWidget(), // ← este sí se actualiza
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Bienvenida
                  FutureBuilder<Map<String, dynamic>?>(
                    future: cargarDatosUsuario(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('Bienvenido'),
                        );
                      }

                      final data = snapshot.data!;
                      final nombre = data['nombre'] ?? 'Usuario';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Bienvenido, $nombre',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    '¡Es hora de tus pastillas!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('medicamentos')
                          .orderBy('hora')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('No hay medicamentos registrados'));
                        }

                        final meds = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: meds.length,
                          itemBuilder: (context, index) {
                            final med = meds[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title:
                                    Text('${med['nombre']} ${med['dosis']}'),
                                subtitle:
                                    Text('${med['cantidad']} comprimido(s)'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check_circle,
                                          color: Colors.green),
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('medicamentos')
                                            .doc(med.id)
                                            .update({'estado': 'tomada'});
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel,
                                          color: Colors.red),
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('medicamentos')
                                            .doc(med.id)
                                            .update({'estado': 'saltada'});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text('Próxima tarea: Caminar 30 min. Hoy a las 10:00 AM'),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.home),
                        label: const Text('VOLVER A CASA'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 207, 55, 4),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.phone),
                        label: const Text('LLAMAR A HIJO'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}