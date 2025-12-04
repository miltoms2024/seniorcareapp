import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PanelUsuario extends StatelessWidget {
  const PanelUsuario({super.key});

  Future<Map<String, dynamic>?> cargarDatosUsuario() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Bienvenido'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('22°C • No hay lluvia', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
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
                    child: Text('No se encontraron datos del usuario.'),
                  );
                }

                final data = snapshot.data!;
                final nombre = data['nombre'] ?? 'Sin nombre';
                final edad = data['edad']?.toString() ?? 'Sin edad';
                final ciudad = data['ciudad'] ?? 'Sin ciudad';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('👤 Nombre: $nombre', style: const TextStyle(fontSize: 18)),
                      Text('🎂 Edad: $edad', style: const TextStyle(fontSize: 18)),
                      Text('🏙️ Ciudad: $ciudad', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text('¡Es hora de tus pastillas!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('medicamentos').orderBy('hora').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No hay medicamentos registrados'));
                  }

                  final meds = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: meds.length,
                    itemBuilder: (context, index) {
                      final med = meds[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('${med['nombre']} ${med['dosis']}'),
                          subtitle: Text('${med['cantidad']} comprimido(s)'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green),
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('medicamentos')
                                      .doc(med.id)
                                      .update({'estado': 'tomada'});
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red),
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
                  onPressed: () {
                    // lógica para volver a casa
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('VOLVER A CASA'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // lógica para llamar al hijo
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('LLAMAR A HIJO'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}