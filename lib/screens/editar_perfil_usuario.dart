import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'gestionar_contactos.dart';

class EditarPerfilUsuario extends StatefulWidget {
  const EditarPerfilUsuario({super.key});

  @override
  State<EditarPerfilUsuario> createState() => _EditarPerfilUsuarioState();
}

class _EditarPerfilUsuarioState extends State<EditarPerfilUsuario> {
  final nombreCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final edadCtrl = TextEditingController();

  String genero = "Masculino";
  bool siesta = false;

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    direccionCtrl.dispose();
    telefonoCtrl.dispose();
    edadCtrl.dispose();
    super.dispose();
  }

  Future<void> cargarDatos() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/inicio');
        return;
      }

      final uid = user.uid;
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        nombreCtrl.text = data["nombre"] ?? "";
        direccionCtrl.text = data["direccion"] ?? "";
        telefonoCtrl.text = data["telefono_hijo"] ?? "";
        edadCtrl.text = data["edad"]?.toString() ?? "";
        genero = data["genero"] ?? "Masculino";
        siesta = data["siesta"] ?? false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  Future<void> guardar() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión no válida. Por favor inicia sesión.')),
        );
        Navigator.pushReplacementNamed(context, '/inicio');
        return;
      }

      final uid = user.uid;

      // --- GEOCODING: convertir dirección a coordenadas ---
      double? lat;
      double? lng;

      if (direccionCtrl.text.isNotEmpty) {
        try {
          final locations = await locationFromAddress(direccionCtrl.text);
          if (locations.isNotEmpty) {
            lat = locations.first.latitude;
            lng = locations.first.longitude;
          }
        } catch (e) {
          lat = null;
          lng = null;
        }
      }

      // --- GUARDAR EN FIRESTORE ---
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        "nombre": nombreCtrl.text,
        "direccion": direccionCtrl.text,
        "telefono_hijo": telefonoCtrl.text,
        "edad": int.tryParse(edadCtrl.text) ?? 0,
        "genero": genero,
        "siesta": siesta,
        "latitud": lat,
        "longitud": lng,
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        backgroundColor: const Color(0xFFB8E0D2),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: "Nombre",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: edadCtrl,
                    decoration: const InputDecoration(
                      labelText: "Edad",
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: genero,
                    decoration: const InputDecoration(
                      labelText: "Género",
                      prefixIcon: Icon(Icons.wc),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Masculino", child: Text("Masculino")),
                      DropdownMenuItem(value: "Femenino", child: Text("Femenino")),
                      DropdownMenuItem(value: "Otro", child: Text("Otro")),
                    ],
                    onChanged: (v) => setState(() => genero = v ?? genero),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: direccionCtrl,
                    decoration: const InputDecoration(
                      labelText: "Dirección",
                      prefixIcon: Icon(Icons.home),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: telefonoCtrl,
                    decoration: const InputDecoration(
                      labelText: "Teléfono del hijo",
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("¿Hace siesta?", style: TextStyle(fontSize: 18)),
                      Switch(
                        value: siesta,
                        onChanged: (v) => setState(() => siesta = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GestionarContactos()),
                      );
                    },
                    icon: const Icon(Icons.contacts),
                    label: const Text("Gestionar contactos"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: guardar,
                    icon: const Icon(Icons.save),
                    label: const Text("Guardar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
