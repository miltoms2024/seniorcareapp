import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class ListaMedicamentosScreen extends StatelessWidget {
  const ListaMedicamentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicamentos"),
        backgroundColor: Color.fromARGB(255, 218, 237, 230),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/panel');
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => _buildEleganteModal(context),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder(
        stream: _unifiedStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No hay medicamentos registrados",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final meds = snapshot.data!;

          return ListView.builder(
            itemCount: meds.length,
            itemBuilder: (context, index) {
              final med = meds[index];
              final tipo = med['tipo'];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    med['titulo'] ?? med['nombre_medicina'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _buildSubtitle(med),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: _buildTipoChip(tipo),
                  trailing: Switch(
                    value: med['activo'] ?? true,
                    onChanged: (value) => _toggleActivo(med, value),
                  ),

                  // 🔥 BORRADO POR PULSACIÓN LARGA
                  onLongPress: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Eliminar"),
                        content: const Text(
                          "¿Quieres borrar este medicamento?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Eliminar"),
                          ),
                        ],
                      ),
                    );

                    if (confirmar == true) {
                      final collection = tipo == 'eventual'
                          ? 'tratamientos_eventuales'
                          : 'medicamentos';

                      await FirebaseFirestore.instance
                          .collection(collection)
                          .doc(med['id'])
                          .delete();
                    }
                  },

                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      tipo == "eventual"
                          ? '/editar_medicamento_eventual'
                          : '/editar_medicamento_pautado',
                      arguments: med,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STREAM UNIFICADO (medicamentos + eventuales)
  // ─────────────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> _unifiedStream() {
    final pautados = FirebaseFirestore.instance
        .collection('medicamentos')
        .snapshots();

    final eventuales = FirebaseFirestore.instance
        .collection('tratamientos_eventuales')
        .snapshots();

    return Rx.combineLatest2(pautados, eventuales, (
      QuerySnapshot p,
      QuerySnapshot e,
    ) {
      final lista = <Map<String, dynamic>>[];

      for (var d in p.docs) {
        final data = d.data() as Map<String, dynamic>;
        data['id'] = d.id;
        data['tipo'] = 'medicacion';
        lista.add(data);
      }

      for (var d in e.docs) {
        final data = d.data() as Map<String, dynamic>;
        data['id'] = d.id;
        data['tipo'] = 'eventual';
        lista.add(data);
      }

      lista.sort(
        (a, b) => a['titulo'].toString().compareTo(b['titulo'].toString()),
      );

      return lista;
    });
  }

  // ─────────────────────────────────────────────────────────────
  // SUBTÍTULO
  // ─────────────────────────────────────────────────────────────

  String _buildSubtitle(Map<String, dynamic> med) {
    final dosis = med['dosis'] ?? "—";
    final via = med['via'] ?? "—";
    final hora = med['hora'] ?? med['hora_referencia'] ?? "—";

    if (med['tipo'] == 'eventual') {
      final motivo = med['motivo_uso'] ?? "—";
      return "Dosis: $dosis\n"
          "Vía: $via\n"
          "Motivo: $motivo\n"
          "Hora ref: $hora";
    }

    final frecuencia = med['frecuencia_horas']?.toString() ?? "—";

    return "Dosis: $dosis\n"
        "Vía: $via\n"
        "Hora: $hora\n"
        "Frecuencia: $frecuencia h";
  }

  // ─────────────────────────────────────────────────────────────
  // CHIP
  // ─────────────────────────────────────────────────────────────

  Widget _buildTipoChip(String tipo) {
    switch (tipo) {
      case 'medicacion':
        return const Chip(label: Text("Pautado"));
      case 'eventual':
        return const Chip(label: Text("Eventual"));
      default:
        return const Chip(label: Text("Otro"));
    }
  }

  // ─────────────────────────────────────────────────────────────
  // INTERRUPTOR
  // ─────────────────────────────────────────────────────────────

  Future<void> _toggleActivo(Map<String, dynamic> med, bool value) async {
    final tipo = med['tipo'];
    final id = med['id'];

    final collection = tipo == 'eventual'
        ? 'tratamientos_eventuales'
        : 'medicamentos';

    await FirebaseFirestore.instance.collection(collection).doc(id).update({
      'activo': value,
    });
  }
}

// ─────────────────────────────────────────────────────────────
//   MODAL ELEGANTE
// ─────────────────────────────────────────────────────────────

Widget _buildEleganteModal(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Tipo de tratamiento",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        _opcionCard(
          context,
          icon: Icons.access_time_filled,
          color: Colors.blueAccent.shade100,
          titulo: "Larga duración",
          descripcion: "Tratamientos de por vida o meses.",
          ruta: "/agregar_medicamento_largo",
        ),

        const SizedBox(height: 12),

        _opcionCard(
          context,
          icon: Icons.calendar_month,
          color: Colors.greenAccent.shade100,
          titulo: "Corta duración",
          descripcion: "Tratamientos de días o semanas.",
          ruta: "/agregar_medicamento_corto",
        ),

        const SizedBox(height: 12),

        _opcionCard(
          context,
          icon: Icons.medical_services,
          color: Colors.orangeAccent.shade100,
          titulo: "Eventual",
          descripcion: "Usos puntuales: gotas, cremas, colirios.",
          ruta: "/agregar_medicamento_eventual",
        ),
      ],
    ),
  );
}

Widget _opcionCard(
  BuildContext context, {
  required IconData icon,
  required Color color,
  required String titulo,
  required String descripcion,
  required String ruta,
}) {
  return InkWell(
    onTap: () {
      Navigator.pop(context);
      Navigator.pushNamed(context, ruta);
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.black87),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(descripcion, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
