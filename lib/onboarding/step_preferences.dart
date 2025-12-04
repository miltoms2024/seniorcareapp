import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'onboarding_controller.dart';
import 'package:seniorcareapp/screens/home_screen.dart';

class StepPreferences extends StatelessWidget {
  final VoidCallback? onFinish;

  const StepPreferences({super.key, this.onFinish});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<OnboardingController>(context);

    final actividadesDisponibles = ['Caminar', 'Leer', 'Música', 'Jardinería', 'Pintar'];
    final nivelesEnergia = ['Baja', 'Media', 'Alta'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Nombre'),
            onChanged: (value) => controller.actualizarIdentidad(
              nombre: value,
              edad: controller.edad,
              genero: controller.genero,
            ),
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Edad'),
            keyboardType: TextInputType.number,
            onChanged: (value) => controller.actualizarIdentidad(
              nombre: controller.nombre,
              edad: value,
              genero: controller.genero,
            ),
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Género'),
            onChanged: (value) => controller.actualizarIdentidad(
              nombre: controller.nombre,
              edad: controller.edad,
              genero: value,
            ),
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Desayuno'),
            onChanged: (value) => controller.actualizarRutina(
              desayuno: value,
              almuerzo: controller.almuerzo,
              cena: controller.cena,
            ),
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Almuerzo'),
            onChanged: (value) => controller.actualizarRutina(
              desayuno: controller.desayuno,
              almuerzo: value,
              cena: controller.cena,
            ),
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Cena'),
            onChanged: (value) => controller.actualizarRutina(
              desayuno: controller.desayuno,
              almuerzo: controller.almuerzo,
              cena: value,
            ),
          ),
          const SizedBox(height: 24),
          Text('Actividades favoritas:', style: Theme.of(context).textTheme.titleMedium),
          Wrap(
            spacing: 8,
            children: actividadesDisponibles.map((actividad) {
              final seleccionada = controller.actividades.contains(actividad);
              return FilterChip(
                label: Text(actividad),
                selected: seleccionada,
                onSelected: (selected) {
                  final nuevas = List<String>.from(controller.actividades);
                  if (selected && !nuevas.contains(actividad)) {
                    nuevas.add(actividad);
                  } else if (!selected) {
                    nuevas.remove(actividad);
                  }
                  controller.actualizarPreferencias(
                    actividades: nuevas,
                    energia: controller.energia,
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Nivel de energía:', style: Theme.of(context).textTheme.titleMedium),
          DropdownButton<String>(
            value: controller.energia.isEmpty ? null : controller.energia,
            hint: const Text('Selecciona tu energía'),
            items: nivelesEnergia.map((nivel) {
              return DropdownMenuItem(value: nivel, child: Text(nivel));
            }).toList(),
            onChanged: (value) {
              controller.actualizarPreferencias(
                actividades: controller.actividades,
                energia: value ?? '',
              );
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              await controller.guardarEnFirestore();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Datos guardados con éxito')),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            },
            child: const Text("Finalizar"),
          ),
        ],
      ),
    );
  }
}