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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
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
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              final controller = Provider.of<OnboardingController>(context, listen: false);
              controller.actualizarIdentidad(
                nombre: _nombreController.text,
                edad: _edadController.text,
                genero: _genero,
              );
              widget.onNext();
            },
            child: const Text("Siguiente"),
          ),
        ],
      ),
    );
  }
}