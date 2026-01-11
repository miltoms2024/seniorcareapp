import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerfilUsuario extends StatelessWidget {
  const PerfilUsuario({super.key});

  Future<Map<String, dynamic>?> cargarDatos() async {
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
    final width = MediaQuery.of(context).size.width;

    // ✅ Ajuste responsive
    double maxWidth;
    if (width < 500) {
      maxWidth = width; // móvil
    } else if (width < 900) {
      maxWidth = 600; // portátil
    } else {
      maxWidth = 900; // escritorio
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      appBar: AppBar(
        title: const Text("Perfil del Usuario"),
        backgroundColor: const Color(0xFFB8E0D2),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: cargarDatos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                    child: Text("No se encontraron datos del usuario."));
              }

              final data = snapshot.data!;

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _seccion(
                    "Información Personal",
                    [
                      _item("Nombre", data["nombre"]),
                      _item("Edad", data["edad"]),
                      _item("Género", data["genero"]),
                    ],
                  ),

                  _seccion(
                    "Rutina",
                    [
                      _item("Desayuno", data["desayuno"]),
                      _item("Almuerzo", data["almuerzo"]),
                      _item("Cena", data["cena"]),
                      _item("Siesta", data["siesta"] == true ? "Sí" : "No"),
                    ],
                  ),

                  _seccion(
                    "Preferencias",
                    [
                      _item("Energía", data["energía"]),
                      _item("Actividad", (data["actividades"]?[0] ?? "")),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ✅ Tarjeta de sección
  Widget _seccion(String titulo, List<Widget> contenido) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            ...contenido,
          ],
        ),
      ),
    );
  }

  // ✅ Fila de dato
  Widget _item(String titulo, dynamic valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 18)),
          Text(
            valor?.toString() ?? "—",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}