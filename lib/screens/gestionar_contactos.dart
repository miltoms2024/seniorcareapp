import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GestionarContactos extends StatefulWidget {
  const GestionarContactos({super.key});

  @override
  State<GestionarContactos> createState() => _GestionarContactosState();
}

class _GestionarContactosState extends State<GestionarContactos> {
  bool cargando = true;

  // Contacto principal
  final nombrePrincipalCtrl = TextEditingController();
  final parentescoPrincipalCtrl = TextEditingController();
  final telefonoPrincipalCtrl = TextEditingController();

  // Contactos adicionales
  List<Map<String, TextEditingController>> contactosAdicionales = [];

  @override
  void initState() {
    super.initState();
    cargarContactos();
  }

  Future<void> cargarContactos() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();

    if (doc.exists && doc.data()!.containsKey("contactos")) {
      final lista = List<Map<String, dynamic>>.from(doc["contactos"]);

      // Buscar principal
      final principal = lista.firstWhere(
        (c) => c["principal"] == true,
        orElse: () => {},
      );

      if (principal.isNotEmpty) {
        nombrePrincipalCtrl.text = principal["nombre"] ?? "";
        parentescoPrincipalCtrl.text = principal["parentesco"] ?? "";
        telefonoPrincipalCtrl.text = principal["telefono"] ?? "";
      }

      // Cargar adicionales
      final adicionales = lista.where((c) => c["principal"] == false).toList();

      for (var c in adicionales) {
        contactosAdicionales.add({
          "nombre": TextEditingController(text: c["nombre"]),
          "parentesco": TextEditingController(text: c["parentesco"]),
          "telefono": TextEditingController(text: c["telefono"]),
        });
      }
    }

    setState(() => cargando = false);
  }

  Future<void> guardar() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Construir lista final
    List<Map<String, dynamic>> listaFinal = [];

    // Principal
    listaFinal.add({
      "nombre": nombrePrincipalCtrl.text,
      "parentesco": parentescoPrincipalCtrl.text,
      "telefono": telefonoPrincipalCtrl.text,
      "principal": true,
    });

    // Adicionales
    for (var c in contactosAdicionales) {
      listaFinal.add({
        "nombre": c["nombre"]!.text,
        "parentesco": c["parentesco"]!.text,
        "telefono": c["telefono"]!.text,
        "principal": false,
      });
    }

    await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
      "contactos": listaFinal,
    }, SetOptions(merge: true));

    Navigator.pop(context);
  }

  void agregarContacto() {
    if (contactosAdicionales.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Máximo 4 contactos adicionales")),
      );
      return;
    }

    setState(() {
      contactosAdicionales.add({
        "nombre": TextEditingController(),
        "parentesco": TextEditingController(),
        "telefono": TextEditingController(),
      });
    });
  }

  void eliminarContacto(int index) {
    setState(() {
      contactosAdicionales.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestionar contactos"),
        backgroundColor: const Color(0xFFB8E0D2),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  const Text(
                    "Contacto principal",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: nombrePrincipalCtrl,
                    decoration: const InputDecoration(
                      labelText: "Nombre",
                      hintText: "Ej: Pedro",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: parentescoPrincipalCtrl,
                    decoration: const InputDecoration(
                      labelText: "Parentesco",
                      hintText: "Ej: Hijo",
                      prefixIcon: Icon(Icons.family_restroom),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: telefonoPrincipalCtrl,
                    decoration: const InputDecoration(
                      labelText: "Teléfono",
                      hintText: "Ej: 600123456",
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 20),

                  const Text(
                    "Contactos adicionales",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  ...List.generate(contactosAdicionales.length, (index) {
                    final c = contactosAdicionales[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextField(
                              controller: c["nombre"],
                              decoration: const InputDecoration(
                                labelText: "Nombre",
                                hintText: "Ej: Juan",
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(height: 12),

                            TextField(
                              controller: c["parentesco"],
                              decoration: const InputDecoration(
                                labelText: "Parentesco",
                                hintText: "Ej: Hermano",
                                prefixIcon: Icon(Icons.family_restroom),
                              ),
                            ),
                            const SizedBox(height: 12),

                            TextField(
                              controller: c["telefono"],
                              decoration: const InputDecoration(
                                labelText: "Teléfono",
                                hintText: "Ej: 600987654",
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),

                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => eliminarContacto(index),
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: const Text("Eliminar", style: TextStyle(color: Colors.red)),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: agregarContacto,
                    icon: const Icon(Icons.add),
                    label: const Text("Añadir contacto"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 40),

                  ElevatedButton.icon(
                    onPressed: guardar,
                    icon: const Icon(Icons.save),
                    label: const Text("Guardar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}