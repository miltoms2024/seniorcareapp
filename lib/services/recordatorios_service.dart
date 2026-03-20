import 'package:cloud_firestore/cloud_firestore.dart';

class RecordatoriosService {
  static final _db = FirebaseFirestore.instance;
  static final _coleccion = _db.collection('recordatorios');

  /// Crear un nuevo recordatorio
  static Future<String> crearRecordatorio({
    required String tipo,
    required String titulo,
    required String descripcion,
    required String hora,
    required List<String> dias,
    required bool activo,
    String? origen,
    String? idOrigen,
  }) async {
    final doc = await _coleccion.add({
      'tipo': tipo,
      'titulo': titulo,
      'descripcion': descripcion,
      'hora': hora,
      'dias': dias,
      'activo': activo,
      'origen': origen,
      'id_origen': idOrigen,
      'creado_en': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  /// Actualizar un recordatorio existente
  static Future<void> actualizarRecordatorio(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _coleccion.doc(id).update(data);
  }

  /// Borrar un recordatorio
  static Future<void> borrarRecordatorio(String id) async {
    await _coleccion.doc(id).delete();
  }

  /// Buscar un recordatorio por origen (medicación, actividad, etc.)
  static Future<QueryDocumentSnapshot?> obtenerPorOrigen(
    String origen,
    String idOrigen,
  ) async {
    final query = await _coleccion
        .where('origen', isEqualTo: origen)
        .where('id_origen', isEqualTo: idOrigen)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return query.docs.first;
  }
}