import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'onboarding_controller.dart';
import '../screens/panel_usuario.dart';

class StepPreferences extends StatelessWidget {
  final VoidCallback? onFinish;

  const StepPreferences({super.key, this.onFinish});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<OnboardingController>(context);

    final actividadesDisponibles = ['Caminar', 'Leer', 'Música', 'Jardinería', 'Pintar'];
    final nivelesEnergia = ['Baja', 'Media', 'Alta'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Preferencias"),
        backgroundColor: const Color(0xFFB8E0D2),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/panel');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ⭐ SOLO RUTINA — SIN GUARDAR NADA AQUÍ

            TextField(
              decoration: const InputDecoration(labelText: 'Desayuno (ej: 7:00–9:00)'),
              onChanged: (value) => controller.actualizarRutina(
                desayuno: value,
                almuerzo: controller.almuerzo,
                cena: controller.cena,
                dormir: controller.dormir,
              ),
            ),

            TextField(
              decoration: const InputDecoration(labelText: 'Almuerzo (ej: 13:00–15:00)'),
              onChanged: (value) => controller.actualizarRutina(
                desayuno: controller.desayuno,
                almuerzo: value,
                cena: controller.cena,
                dormir: controller.dormir,
              ),
            ),

            TextField(
              decoration: const InputDecoration(labelText: 'Cena (ej: 20:00–22:00)'),
              onChanged: (value) => controller.actualizarRutina(
                desayuno: controller.desayuno,
                almuerzo: controller.almuerzo,
                cena: value,
                dormir: controller.dormir,
              ),
            ),

            TextField(
              decoration: const InputDecoration(labelText: 'Dormir–Despertar (ej: 00:30–07:00)'),
              onChanged: (value) => controller.actualizarRutina(
                desayuno: controller.desayuno,
                almuerzo: controller.almuerzo,
                cena: controller.cena,
                dormir: value,
              ),
            ),

            const SizedBox(height: 24),

            // ⭐ ACTIVIDADES FAVORITAS
            Text('Actividades favoritas:', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: actividadesDisponibles.map((actividad) {
                final seleccionada = controller.actividad == actividad;
                return FilterChip(
                  label: Text(actividad),
                  selected: seleccionada,
                  onSelected: (selected) {
                    final nueva = selected ? actividad : '';
                    controller.actualizarPreferencias(
                      actividades: [nueva],
                      energia: controller.energia,
                    );
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ⭐ NIVEL DE ENERGÍA
            Text('Nivel de energía:', style: Theme.of(context).textTheme.titleMedium),
            DropdownButton<String>(
              value: controller.energia.isEmpty ? null : controller.energia,
              hint: const Text('Selecciona tu energía'),
              items: nivelesEnergia.map((nivel) {
                return DropdownMenuItem(value: nivel, child: Text(nivel));
              }).toList(),
              onChanged: (value) {
                controller.actualizarPreferencias(
                  actividades: [controller.actividad],
                  energia: value ?? '',
                );
              },
            ),

            const SizedBox(height: 32),

            // ⭐ BOTÓN SIGUIENTE
            ElevatedButton(
              onPressed: () {
                if (onFinish != null) {
                  onFinish!();
                }
              },
              child: const Text("Siguiente"),
            ),
          ],
        ),
      ),
    );
  }
}
