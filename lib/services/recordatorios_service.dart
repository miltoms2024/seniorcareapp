import 'package:cloud_firestore/cloud_firestore.dart';

class RecordatoriosService {
  static final _db = FirebaseFirestore.instance;

  static final _coleccion = _db.collection('medicamentos');

  static Future<String> crearRecordatorio({
    required String uid,
    required String titulo,
    required String hora,
    required List<String> dias,
    required String tipo,
    required bool activo,
    int? frecuenciaHoras,
    int? duracionDias,
    String? via,
    String? dosis,
  }) async {
    final doc = await _coleccion.add({
      'uid': uid,
      'titulo': titulo,
      'hora': hora,
      'dias': dias,
      'tipo': tipo,
      'activo': activo,
      'frecuencia_horas': frecuenciaHoras,
      'duracion_dias': duracionDias,
      'via': via,
      'dosis': dosis,
      'creado_en': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  static Future<void> actualizarRecordatorio(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _coleccion.doc(id).update(data);
  }

  static Future<void> borrarRecordatorio(String id) async {
    await _coleccion.doc(id).delete();
  }

  static Future<DocumentSnapshot?> obtenerPorId(String id) async {
    final doc = await _coleccion.doc(id).get();
    return doc.exists ? doc : null;
  }
}
