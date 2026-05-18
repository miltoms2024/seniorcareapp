import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'clima_widget.dart';
import 'time_widget.dart';
import '../controllers/app_brain.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seniorcareapp/services/motor_recordatorios.dart';
import 'package:seniorcareapp/models/recordatorio.dart';

class PanelUsuario extends StatefulWidget {
  const PanelUsuario({super.key});

  @override
  State<PanelUsuario> createState() => _PanelUsuarioState();
}

class _PanelUsuarioState extends State<PanelUsuario> {
  Timer? timer;

  List<Recordatorio> recordatoriosHoy = [];
  Recordatorio? recordatorioActual;
  final motor = MotorRecordatorios();

  Future<Map<String, dynamic>?> cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .get();

    return doc.exists ? doc.data() : null;
  }

  void cargarRecordatorios() async {
    final lista = await motor.cargarRecordatoriosDelDia();
    final proximo = motor.obtenerProximoRecordatorio(lista);

    setState(() {
      recordatoriosHoy = lista;
      recordatorioActual = proximo;
    });

   
  }

  @override
  void initState() {
    super.initState();
    cargarRecordatorios();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

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
                  onSelected: (value) async {
                    if (value == 'perfil') {
                      Navigator.pushNamed(context, '/perfil');
                    } else if (value == 'preferencias') {
                      Navigator.pushNamed(context, '/preferencias');
                    } else if (value == 'inicio') {
                      Navigator.pushNamed(context, '/panel');
                    } else if (value == 'lista_medicamentos') {
                      Navigator.pushNamed(context, '/lista_medicamentos');
                    } else if (value == 'logout') {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('registro_completado');
                      await prefs.remove('userId');

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/onboarding',
                        (_) => false,
                      );
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'inicio', child: Text('Inicio')),
                    PopupMenuItem(value: 'perfil', child: Text('Perfil')),
                    PopupMenuItem(value: 'preferencias', child: Text('Preferencias')),
                    PopupMenuItem(value: 'lista_medicamentos', child: Text('Lista de medicamentos')),
                    PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
                  ],
                ),
              ],
            ),

            // 🔥🔥🔥 SCROLL GENERAL PARA EVITAR OVERFLOW 🔥🔥🔥
            body: SingleChildScrollView(
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (recordatorioActual != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recordatorioActual!.titulo,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text("Dosis: ${recordatorioActual!.dosis}"),
                          Text("Hora: ${recordatorioActual!.hora}"),
                        ],
                      ),
                    )
                  else
                    const Text("No hay medicación pendiente."),

                  const SizedBox(height: 24),

                  // 🔥🔥🔥 BOTONES GRANDES Y CENTRADOS 🔥🔥🔥
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: 65,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid == null) return;

                            final doc = await FirebaseFirestore.instance
                                .collection('usuarios')
                                .doc(uid)
                                .get();

                            final lat = doc.data()?['latitud'];
                            final lng = doc.data()?['longitud'];
                            final direccion = doc.data()?['direccion'] ?? "Dirección no disponible";

                            if (lat == null || lng == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No hay coordenadas guardadas'),
                                ),
                              );
                              return;
                            }

                            mostrarModalConfirmacion(
                              context,
                              lat,
                              lng,
                              direccion,
                            );
                          },
                          icon: const Icon(Icons.home, size: 30),
                          label: const Text(
                            'VOLVER A CASA',
                            style: TextStyle(fontSize: 22),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 207, 55, 4),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: 65,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid == null) return;

                            final doc = await FirebaseFirestore.instance
                                .collection('usuarios')
                                .doc(uid)
                                .get();

                            if (!doc.exists || !doc.data()!.containsKey("contactos")) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("No hay contactos guardados"),
                                ),
                              );
                              return;
                            }

                            final contactos = List<Map<String, dynamic>>.from(doc["contactos"]);

                            if (contactos.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("No hay contactos disponibles"),
                                ),
                              );
                              return;
                            }

                            final principal = contactos.firstWhere(
                              (c) => c["principal"] == true,
                              orElse: () => {},
                            );

                            if (contactos.length == 1 && principal.isNotEmpty) {
                              final telefono = principal["telefono"];
                              final nombre = principal["nombre"];
                              final parentesco = principal["parentesco"];

                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text("Llamar a $nombre ($parentesco)"),
                                  content: const Text("¿Quieres realizar la llamada?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        final url = Uri.parse("tel:$telefono");
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
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 4,
                                        margin: const EdgeInsets.only(bottom: 16),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                title: Text("Llamar a ${c["nombre"]} (${c["parentesco"]})"),
                                                content: Text("¿Quieres llamar al ${c["telefono"]}?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text("Cancelar"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      final url = Uri.parse("tel:${c["telefono"]}");
                                                      if (await canLaunchUrl(url)) {
                                                        await launchUrl(url);
                                                      }
                                                    },
                                                    child: const Text("Llamar"),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.phone, size: 32, color: Colors.green),
                                                const SizedBox(width: 16),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${c["nombre"]} – ${c["parentesco"]}",
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      c["telefono"],
                                                      style: const TextStyle(fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),

                                    const SizedBox(height: 20),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancelar", style: TextStyle(fontSize: 18)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.phone, size: 30),
                          label: const Text(
                            'LLAMAR A CONTACTO',
                            style: TextStyle(fontSize: 22),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
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
}

// ─────────────────────────────────────────────
// MODAL DE CONFIRMACIÓN PARA VOLVER A CASA (CON SALIR)
// ─────────────────────────────────────────────

void mostrarModalConfirmacion(
  BuildContext context,
  double lat,
  double lng,
  String direccion,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const Icon(Icons.home, size: 60, color: Colors.teal),
              const SizedBox(height: 10),

              const Text(
                "¿Quieres ir a esta dirección?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                direccion,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),

              const SizedBox(height: 25),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  abrirGoogleMaps(lat, lng);
                },
                icon: const Icon(Icons.navigation),
                label: const Text("Sí, guiarme ahora"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  mostrarModalCambiarDireccion(context);
                },
                icon: const Icon(Icons.edit_location_alt),
                label: const Text("Cambiar dirección"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Salir",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────
// MODAL PARA DIRECCIÓN PUNTUAL
// ─────────────────────────────────────────────

void mostrarModalCambiarDireccion(BuildContext context) {
  final TextEditingController direccionController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          "Nueva dirección o lugar puntual",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Escribe una dirección puntual o un lugar de interés.\n"
                "Ejemplos: farmacia, panadería, estación Renfe, Eroski…",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: direccionController,
                decoration: const InputDecoration(
                  labelText: "Dirección o lugar puntual",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  final nuevaDireccion = direccionController.text.trim();
                  if (nuevaDireccion.isEmpty) return;

                  Navigator.pop(context);
                  abrirGoogleMapsTexto(nuevaDireccion);
                },
                child: const Text("Usar en Maps"),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────
// GOOGLE MAPS
// ─────────────────────────────────────────────

void abrirGoogleMaps(double lat, double lng) async {
  final url =
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking";

  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

void abrirGoogleMapsTexto(String texto) async {
  final url = Uri.encodeFull(
    "https://www.google.com/maps/dir/?api=1&destination=$texto&travelmode=walking",
  );

  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
