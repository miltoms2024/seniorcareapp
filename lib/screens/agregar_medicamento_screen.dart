import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarMedicamentoScreen extends StatefulWidget {
  const AgregarMedicamentoScreen({super.key});

  @override
  State<AgregarMedicamentoScreen> createState() => _AgregarMedicamentoScreenState();
}

class _AgregarMedicamentoScreenState extends State<AgregarMedicamentoScreen> {
  final nombreController = TextEditingController();
  final dosisController = TextEditingController();
  final frecuenciaHorasController = TextEditingController();

  TimeOfDay? horaSeleccionada;

  final vias = ['Oral', 'Inyectable', 'Tópica'];
  String viaSeleccionada = 'Oral';

  void guardarMedicamento() async {
    final nombre = nombreController.text.trim();
    final dosis = dosisController.text.trim();
    final frecuenciaStr = frecuenciaHorasController.text.trim();

    if (nombre.isEmpty || dosis.isEmpty || frecuenciaStr.isEmpty || horaSeleccionada == null) return;

    final frecuenciaHoras = int.tryParse(frecuenciaStr);
    if (frecuenciaHoras == null) return;

    final horaString =
        "${horaSeleccionada!.hour.toString().padLeft(2, '0')}:${horaSeleccionada!.minute.toString().padLeft(2, '0')}";

    await FirebaseFirestore.instance.collection('medicaciones_programadas').add({
      'nombre_medicina': nombre,
      'dosis': dosis,
      'via': viaSeleccionada,
      'hora_referencia': horaString,
      'frecuencia_horas': frecuenciaHoras,
      'activo': true,
    });

    if (!mounted) return;
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
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del medicamento'),
            ),
            TextField(
              controller: dosisController,
              decoration: const InputDecoration(labelText: 'Dosis (ej: 1 cápsula)'),
            ),
            TextField(
              controller: frecuenciaHorasController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Frecuencia en horas (ej: 24)'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () async {
                final seleccion = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (seleccion != null) {
                  setState(() {
                    horaSeleccionada = seleccion;
                  });
                }
              },
              child: Text(
                horaSeleccionada == null
                    ? "Seleccionar hora"
                    : "Hora: ${horaSeleccionada!.hour.toString().padLeft(2, '0')}:${horaSeleccionada!.minute.toString().padLeft(2, '0')}",
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: viaSeleccionada,
              decoration: const InputDecoration(labelText: 'Vía'),
              items: vias
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => viaSeleccionada = value);
                }
              },
            ),

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