import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/motor_recordatorios.dart';

class AgregarMedicamentoLargoScreen extends StatefulWidget {
  const AgregarMedicamentoLargoScreen({super.key});

  @override
  State<AgregarMedicamentoLargoScreen> createState() =>
      _AgregarMedicamentoLargoScreenState();
}

class _AgregarMedicamentoLargoScreenState
    extends State<AgregarMedicamentoLargoScreen> {
  final nombreController = TextEditingController();
  final dosisController = TextEditingController();
  final frecuenciaHorasController = TextEditingController();

  TimeOfDay? horaSeleccionada;

  final vias = ['Oral', 'Inyectable', 'Tópica'];
  String viaSeleccionada = 'Oral';

  final diasSemana = [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
    "Sábado",
    "Domingo"
  ];

  List<String> diasSeleccionados = [];

  // -----------------------------------------------------------
  // GUARDAR MEDICAMENTO (MODIFICADO CON SINCRONIZACIÓN)
  // -----------------------------------------------------------
  void guardarMedicamento() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final nombre = nombreController.text.trim();
    final dosis = dosisController.text.trim();
    final frecuenciaStr = frecuenciaHorasController.text.trim();

    if (nombre.isEmpty ||
        dosis.isEmpty ||
        frecuenciaStr.isEmpty ||
        horaSeleccionada == null ||
        diasSeleccionados.isEmpty) return;

    final frecuenciaHoras = int.tryParse(frecuenciaStr);
    if (frecuenciaHoras == null) return;

    final horaString =
        "${horaSeleccionada!.hour.toString().padLeft(2, '0')}:${horaSeleccionada!.minute.toString().padLeft(2, '0')}";

    // 🔥 Generar todas las tomas con el motor
    await MotorRecordatorios().generarRecordatoriosPautados(
      uid: uid,
      titulo: nombre,
      dosis: dosis,
      via: viaSeleccionada,
      hora: horaString,
      dias: diasSeleccionados,
      frecuenciaHoras: frecuenciaHoras,
      duracionDias: null,
    );

    // 🔥 SINCRONIZACIÓN CORRECTA (sin bucles)
    await MotorRecordatorios().sincronizarConNotificaciones(null);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tratamiento de larga duración')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nombreController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del medicamento'),
              ),
              TextField(
                controller: dosisController,
                decoration:
                    const InputDecoration(labelText: 'Dosis (ej: 1 cápsula)'),
              ),
              TextField(
                controller: frecuenciaHorasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Frecuencia en horas (ej: 24)'),
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

              const Text("Días de la semana",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: diasSemana.map((dia) {
                  final seleccionado = diasSeleccionados.contains(dia);
                  return FilterChip(
                    label: Text(dia),
                    selected: seleccionado,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          diasSeleccionados.add(dia);
                        } else {
                          diasSeleccionados.remove(dia);
                        }
                      });
                    },
                  );
                }).toList(),
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
