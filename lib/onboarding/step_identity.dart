import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'onboarding_controller.dart';

class StepIdentity extends StatefulWidget {
  final VoidCallback onNext;
  const StepIdentity({super.key, required this.onNext});

  @override
  State<StepIdentity> createState() => _StepIdentityState();
}

class _StepIdentityState extends State<StepIdentity> {
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  String _genero = 'Masculino';

  String _desayuno = '7:00–9:00';
  String _almuerzo = '13:00–15:00';
  String _cena = '20:00–22:00';
  bool _siesta = false;

  String _energia = 'Normal';
  String _actividad = 'Caminar';
  final _otraActividadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(   // ✅ evita overflow
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text("¿Cómo te llamas?", style: TextStyle(fontSize: 20)),
            TextField(controller: _nombreController),
            const SizedBox(height: 16),

            const Text("¿Cuántos años tienes?", style: TextStyle(fontSize: 20)),
            TextField(controller: _edadController, keyboardType: TextInputType.number),
            const SizedBox(height: 16),

            const Text("¿Cuál es tu género?", style: TextStyle(fontSize: 20)),
            DropdownButton<String>(
              value: _genero,
              items: ['Masculino', 'Femenino', 'Otro']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (valor) => setState(() => _genero = valor!),
            ),
            const SizedBox(height: 16),

            const Text("Desayuno", style: TextStyle(fontSize: 20)),
            DropdownButton<String>(
              value: _desayuno,
              items: [
                '7:00–9:00',
                '9:00–11:00',
                '11:00–13:00',
              ].map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
              onChanged: (v) => setState(() => _desayuno = v!),
            ),
            const SizedBox(height: 16),

            const Text("Almuerzo", style: TextStyle(fontSize: 20)),
            DropdownButton<String>(
              value: _almuerzo,
              items: [
                '12:00–14:00',
                '13:00–15:00',
                '14:00–16:00',
              ].map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
              onChanged: (v) => setState(() => _almuerzo = v!),
            ),
            const SizedBox(height: 16),

            const Text("Cena", style: TextStyle(fontSize: 20)),
            DropdownButton<String>(
              value: _cena,
              items: [
                '19:00–21:00',
                '20:00–22:00',
                '21:00–23:00',
              ].map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
              onChanged: (v) => setState(() => _cena = v!),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Text("¿Haces siesta?", style: TextStyle(fontSize: 20)),
                Switch(
                  value: _siesta,
                  onChanged: (v) => setState(() => _siesta = v),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text("¿Cómo amaneciste hoy?", style: TextStyle(fontSize: 20)),
            DropdownButton<String>(
              value: _energia,
              items: [
                'Muy bien',
                'Bien',
                'Normal',
                'Cansado',
                'Muy cansado',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _energia = v!),
            ),
            const SizedBox(height: 16),

            const Text("Actividad principal", style: TextStyle(fontSize: 20)),
            DropdownButton<String>(
              value: _actividad,
              items: [
                'Caminar',
                'Leer',
                'Ver TV',
                'Jardinería',
                'Pasear',
                'Otro',
              ].map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
              onChanged: (v) => setState(() => _actividad = v!),
            ),

            if (_actividad == 'Otro')
              TextField(
                controller: _otraActividadController,
                decoration: const InputDecoration(hintText: "Especifica la actividad"),
              ),

            const SizedBox(height: 32),   // ✅ reemplaza Spacer()

            ElevatedButton(
              onPressed: () {
                final controller = Provider.of<OnboardingController>(context, listen: false);

                controller.actualizarIdentidad(
                  nombre: _nombreController.text,
                  edad: _edadController.text,
                  genero: _genero,
                );

                controller.actualizarRutina(
                  desayuno: _desayuno,
                  almuerzo: _almuerzo,
                  cena: _cena,
                  dormir: controller.dormir,
                );

                controller.actualizarPreferencias(
                  actividades: [
                    _actividad == 'Otro'
                        ? _otraActividadController.text
                        : _actividad
                  ],
                  energia: _energia,
                );

                widget.onNext();
              },
              child: const Text("Siguiente"),
            ),
          ],
        ),
      ),
    );
  }
}