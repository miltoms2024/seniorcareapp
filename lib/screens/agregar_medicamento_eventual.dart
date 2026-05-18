import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/motor_recordatorios.dart';

class AgregarMedicamentoEventualScreen extends StatefulWidget {
  const AgregarMedicamentoEventualScreen({super.key});

  @override
  State<AgregarMedicamentoEventualScreen> createState() =>
      _AgregarMedicamentoEventualScreenState();
}

class _AgregarMedicamentoEventualScreenState
    extends State<AgregarMedicamentoEventualScreen> {
  final nombreController = TextEditingController();
  final dosisController = TextEditingController();
  final motivoController = TextEditingController();

  TimeOfDay? horaSeleccionada;

  final vias = ['Oral', 'Inyectable', 'Tópica', 'Ocular', 'Nasal'];
  String viaSeleccionada = 'Oral';

  // -----------------------------------------------------------
  // GUARDAR MEDICAMENTO EVENTUAL (MODIFICADO CON SINCRONIZACIÓN)
  // -----------------------------------------------------------
  void guardarMedicamento() async {
    final nombre = nombreController.text.trim();
    final dosis = dosisController.text.trim();
    final motivo = motivoController.text.trim();

    if (nombre.isEmpty || dosis.isEmpty || motivo.isEmpty) return;

    String? horaString;

    if (horaSeleccionada != null) {
      horaString =
          "${horaSeleccionada!.hour.toString().padLeft(2, '0')}:${horaSeleccionada!.minute.toString().padLeft(2, '0')}";
    }

    await FirebaseFirestore.instance
        .collection('tratamientos_eventuales')
        .add({
      'nombre_medicina': nombre,
      'dosis': dosis,
      'via': viaSeleccionada,
      'motivo_uso': motivo,
      'hora_referencia': horaString,
      'activo': true,
      'tipo': 'eventual',
    });

    // 🔥 SINCRONIZACIÓN CORRECTA (sin bucles)
    await MotorRecordatorios().sincronizarConNotificaciones(null);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tratamiento eventual')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                    labelText: 'Nombre del medicamento'),
              ),
              TextField(
                controller: dosisController,
                decoration: const InputDecoration(
                    labelText: 'Dosis (ej: 1 aplicación)'),
              ),
              TextField(
                controller: motivoController,
                decoration: const InputDecoration(
                    labelText: 'Motivo de uso (ej: sequedad ocular)'),
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
                      ? "Seleccionar hora (opcional)"
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
      ),
    );
  }
}
