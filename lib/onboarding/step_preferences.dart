import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'onboarding_controller.dart';
import '../screens/panel_usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

          // ✅ IDENTIDAD
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

          // ✅ RUTINA
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

          // ✅ NUEVO CAMPO — DORMIR–DESPERTAR
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

          // ✅ ACTIVIDADES
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

          // ✅ ENERGÍA
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

          // ✅ BOTÓN SIGUIENTE
          ElevatedButton(
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;

              if (uid == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No hay usuario autenticado')),
                );
                return;
              }

              final docRef = FirebaseFirestore.instance.collection('usuarios').doc(uid);

              await docRef.set({
                'nombre': controller.nombre.isNotEmpty ? controller.nombre : 'Usuario Prueba',
                'edad': controller.edad.isNotEmpty ? controller.edad : '75',
                'genero': controller.genero.isNotEmpty ? controller.genero : 'Masculino',

                // ✅ FRANJAS EXACTAS
                'desayuno': controller.desayuno.isNotEmpty ? controller.desayuno : '7:00–9:00',
                'almuerzo': controller.almuerzo.isNotEmpty ? controller.almuerzo : '13:00–15:00',
                'cena': controller.cena.isNotEmpty ? controller.cena : '20:00–22:00',
                'dormir': controller.dormir.isNotEmpty ? controller.dormir : '00:30–07:00',

                'siesta': controller.siesta,
                'actividad': controller.actividad.isNotEmpty ? controller.actividad : 'Caminar',
                'energia': controller.energia.isNotEmpty ? controller.energia : 'Normal',

                'onboardingCompletado': true,
              }, SetOptions(merge: true));

              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                 MaterialPageRoute(builder: (_) => const PanelUsuario()),

                );
              }
            },
            child: const Text("Siguiente"),
          ),
        ],
      ),
    );
  }
}