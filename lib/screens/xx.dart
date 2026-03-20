// *** VERSION CON ALERTAS — GENERADA POR COPILOT ***
// -------------------------------------------------------------
// PANEL DE USUARIO (VERSIÓN MODIFICADA PARA ALERTAS DE MEDICACIÓN)
// -------------------------------------------------------------
// Cambios principales:
//  ✔ StatelessWidget -> StatefulWidget
//  ✔ Timer que revisa medicación cada minuto
//  ✔ revisarMedicacionCronica()
//  ✔ lanzarAlerta()
//  ✔ initState() y dispose()
//  ✔ Se mantienen tus funciones originales y tu UI intacta
// -------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'clima_widget.dart';
import 'time_widget.dart';
import '../controllers/app_brain.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PanelUsuario extends StatefulWidget {
  const PanelUsuario({super.key});

  @override
  State<PanelUsuario> createState() => _PanelUsuarioState();
}

class _PanelUsuarioState extends State<PanelUsuario> {
  Timer? timer;

  // -----------------------------
  // TUS FUNCIONES ORIGINALES
  // -----------------------------
  Future<Map<String, dynamic>?> cargarDatosUsuario() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();

    return doc.exists ? doc.data() : null;
  }

  Future<Map<String, dynamic>?> obtenerProximoMedicamento() async {
    final query = await FirebaseFirestore.instance
        .collection('medicaciones_programadas')
        .where('activo', isEqualTo: true)
        .get();

    if (query.docs.isEmpty) return null;

    final medicamentos = query.docs.map((d) => d.data()).toList();

    medicamentos.sort((a, b) {
      return a['hora_referencia']
          .toString()
          .compareTo(b['hora_referencia'].toString());
    });

    return medicamentos.first;
  }

  Future<void> registrarMedicamentoTomado(Map<String, dynamic> med) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('historial_medicacion').add({
      'uid': uid,
      'nombre_medicina': med['nombre_medicina'],
      'dosis': med['dosis'],
      'via': med['via'],
      'momento': med['hora_referencia'],
      'fecha_tomado': DateTime.now().toIso8601String(),
    });
  }

  // -----------------------------
  // NUEVO: ALERTAS AUTOMÁTICAS
  // -----------------------------
  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      revisarMedicacionCronica();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> revisarMedicacionCronica() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final ahora = TimeOfDay.now();
    final horaActual =
        "${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}";

    final query = await FirebaseFirestore.instance
        .collection('medicaciones_programadas')
        .where('activo', isEqualTo: true)
        .get();

    if (query.docs.isEmpty) return;

    for (var doc in query.docs) {
      final data = doc.data();
      if (data['hora_referencia']?.toString() == horaActual) {
        lanzarAlerta(data);
      }
    }
  }

  void lanzarAlerta(Map<String, dynamic> med) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hora de tomar tu medicación"),
        content: Text(
          "${med['nombre_medicina']} - ${med['dosis']} (${med['via']})\nA las ${med['hora_referencia']}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tomado"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Recordar más tarde"),
          ),
        ],
      ),
    );
  }
// *** VERSION CON ALERTAS — GENERADA POR COPILOT ***
// -------------------------------------------------------------
// MÉTODO BUILD ORIGINAL — NO SE HA MODIFICADO NADA EN LA UI
// -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppBrain(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 238, 235, 235),
            appBar: AppBar(
              title: const Text('SeniorCare – te acompaña en tu día a día'),
              backgroundColor: const Color.fromARGB(255, 218, 237, 230),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'perfil') {
                      Navigator.pushNamed(context, '/perfil');
                    } else if (value == 'preferencias') {
                      Navigator.pushNamed(context, '/preferencias');
                    } else if (value == 'inicio') {
                      Navigator.pushNamed(context, '/panel');
                    } else if (value == 'lista_medicamentos') {
                      Navigator.pushNamed(context, '/lista_medicamentos');
                    } else if (value == 'logout') {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                        value: 'inicio', child: Text('Inicio')),
                    PopupMenuItem(
                        value: 'perfil', child: Text('Perfil')),
                    PopupMenuItem(
                        value: 'preferencias',
                        child: Text('Preferencias')),
                    PopupMenuItem(
                        value: 'lista_medicamentos',
                        child: Text('Lista de medicamentos')),
                    PopupMenuItem(
                        value: 'logout', child: Text('Cerrar sesión')),
                  ],
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ClimaWidget(),
                  const SizedBox(height: 8),
                  const TimeWidget(),
                  const SizedBox(height: 16),
                  FutureBuilder<Map<String, dynamic>?>(
                    future: cargarDatosUsuario(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('Bienvenido'),
                        );
                      }
                      final data = snapshot.data!;
                      final nombre = data['nombre'] ?? 'Usuario';
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Bienvenido, $nombre',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¡Es hora de tus pastillas!',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder(
                    future: obtenerProximoMedicamento(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Text("Cargando medicamentos...");
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Text(
                          "No hay medicamentos registrados",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        );
                      }
                      final med = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Próximo medicamento:",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text("• ${med['nombre_medicina']}"),
                          Text("• Dosis: ${med['dosis']}"),
                          Text("• Vía: ${med['via']}"),
                          Text("• Momento: ${med['hora_referencia']}"),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () async {
                              await registrarMedicamentoTomado(med);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Medicamento registrado como tomado"),
                                ),
                              );
                            },
                            child: const Text("Tomado"),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                      'Próxima tarea: Caminar 30 min. Hoy a las 10:00 AM'),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final uid =
                              FirebaseAuth.instance.currentUser?.uid;
                          if (uid == null) return;

                          final doc = await FirebaseFirestore.instance
                              .collection('usuarios')
                              .doc(uid)
                              .get();

                          final direccion = doc.data()?['direccion'];

                          if (direccion == null || direccion.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'No hay dirección guardada'),
                              ),
                            );
                            return;
                          }

                          final url = Uri.encodeFull(
                              "https://www.google.com/maps/dir/?api=1&destination=$direccion");

                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url),
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.home),
                        label: const Text('VOLVER A CASA'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 207, 55, 4),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final uid =
                              FirebaseAuth.instance.currentUser?.uid;
                          if (uid == null) return;

                          final doc = await FirebaseFirestore.instance
                              .collection('usuarios')
                              .doc(uid)
                              .get();

                          if (!doc.exists ||
                              !doc.data()!.containsKey("contactos")) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "No hay contactos guardados"),
                              ),
                            );
                            return;
                          }

                          final contactos =
                              List<Map<String, dynamic>>.from(
                                  doc["contactos"]);

                          if (contactos.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "No hay contactos disponibles"),
                              ),
                            );
                            return;
                          }

                          final principal = contactos.firstWhere(
                            (c) => c["principal"] == true,
                            orElse: () => {},
                          );

                          if (contactos.length == 1 &&
                              principal.isNotEmpty) {
                            final telefono = principal["telefono"];
                            final nombre = principal["nombre"];
                            final parentesco =
                                principal["parentesco"];

                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(
                                    "Llamar a $nombre ($parentesco)"),
                                content: const Text(
                                    "¿Quieres realizar la llamada?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      final url =
                                          Uri.parse("tel:$telefono");
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      }
                                    },
                                    child: const Text("Llamar"),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          showModalBottomSheet(
                            context: context,
                            builder: (_) {
                              return ListView(
                                padding: const EdgeInsets.all(16),
                                children: [
                                  const Text(
                                    "¿A quién quieres llamar?",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ...contactos.map((c) {
                                    return ListTile(
                                      leading:
                                          const Icon(Icons.phone),
                                      title: Text(
                                          "${c["nombre"]} – ${c["parentesco"]}"),
                                      subtitle:
                                          Text(c["telefono"]),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: Text(
                                                "Llamar a ${c["nombre"]} (${c["parentesco"]})"),
                                            content: Text(
                                                "¿Quieres realizar la llamada al ${c["telefono"]}?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context),
                                                child: const Text(
                                                    "Cancelar"),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(
                                                      context);
                                                  final url = Uri.parse(
                                                      "tel:${c["telefono"]}");
                                                  if (await canLaunchUrl(
                                                      url)) {
                                                    await launchUrl(
                                                        url);
                                                  }
                                                },
                                                child: const Text(
                                                    "Llamar"),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                  const SizedBox(height: 20),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: const Text(
                                      "Cancelar",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('LLAMAR A CONTACTO'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
// *** VERSION CON ALERTAS — GENERADA POR COPILOT ***
// -------------------------------------------------------------
// CIERRE FINAL DEL ARCHIVO
// -------------------------------------------------------------
}
