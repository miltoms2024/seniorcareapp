import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarMedicamentoScreen extends StatefulWidget {
  const AgregarMedicamentoScreen({super.key});

  @override
  State<AgregarMedicamentoScreen> createState() => _AgregarMedicamentoScreenState();
}

class _AgregarMedicamentoScreenState extends State<AgregarMedicamentoScreen> {
  final nombreController = TextEditingController();
  final horaController = TextEditingController();
  final frecuenciaController = TextEditingController();

  void guardarMedicamento() async {
    final nombre = nombreController.text.trim();
    final hora = horaController.text.trim();
    final frecuencia = frecuenciaController.text.trim();

    if (nombre.isEmpty || hora.isEmpty || frecuencia.isEmpty) return;

    await FirebaseFirestore.instance.collection('medicamentos').add({
      'nombre': nombre,
      'hora': hora,
      'frecuencia': frecuencia,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar medicamento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: horaController, decoration: const InputDecoration(labelText: 'Hora')),
            TextField(controller: frecuenciaController, decoration: const InputDecoration(labelText: 'Frecuencia')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: guardarMedicamento,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}