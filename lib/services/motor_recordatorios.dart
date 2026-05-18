import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recordatorio.dart';
import 'alertas_service.dart';

class MotorRecordatorios {
  // -----------------------------------------------------------
  // 1) Cargar recordatorios del día
  // -----------------------------------------------------------
  Future<List<Recordatorio>> cargarRecordatoriosDelDia() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('medicamentos')
        .where('uid', isEqualTo: uid)
        .where('activo', isEqualTo: true)
        .get();

    final hoy = DateTime.now();
    final diaSemana = _diaSemanaTexto(hoy.weekday);

    List<Recordatorio> lista = [];

    for (var doc in snapshot.docs) {
      final r = Recordatorio.fromFirestore(doc);

      if (!r.dias.contains(diaSemana)) continue;

      lista.add(r);
    }

    lista.sort((a, b) => a.horaDateTime.compareTo(b.horaDateTime));

    return lista;
  }

  // -----------------------------------------------------------
  // 2) Obtener el próximo recordatorio
  // -----------------------------------------------------------
  Recordatorio? obtenerProximoRecordatorio(List<Recordatorio> lista) {
    final ahora = DateTime.now();

    for (var r in lista) {
      if (r.horaDateTime.isAfter(ahora)) {
        return r;
      }
    }
    return null;
  }

  // -----------------------------------------------------------
  // 3) Mantener recordatorio activo
  // -----------------------------------------------------------
  Recordatorio? mantenerRecordatorioActivo(
      Recordatorio? actual, List<Recordatorio> lista) {
    if (actual == null) return null;

    final existe = lista.any((r) =>
        r.id == actual.id &&
        r.hora == actual.hora &&
        r.titulo == actual.titulo);

    return existe ? actual : null;
  }

  // -----------------------------------------------------------
  // 4) Marcar como tomado
  // -----------------------------------------------------------
  Future<void> marcarComoTomado(Recordatorio r) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('historial_medicacion').add({
      'uid': uid,
      'titulo': r.titulo,
      'hora_programada': r.hora,
      'fecha_tomado': DateTime.now().toIso8601String(),
      'id_recordatorio': r.id,
    });
  }

  // -----------------------------------------------------------
  // 5) Sincronizar con notificaciones
  // -----------------------------------------------------------
  Future<void> sincronizarConNotificaciones(Recordatorio? proximo) async {
    await AlertasService.cancelarTodas();

    if (proximo == null) return;

    await AlertasService.programarAlerta(
      id: proximo.hashCode,
      titulo: proximo.titulo,
      cuerpo: "Es hora de tomar tu medicación",
      fecha: proximo.horaDateTime,
    );
  }

  // -----------------------------------------------------------
  // 6) GUARDAR MEDICAMENTO (YA NO GENERA RECORDATORIOS)
  // -----------------------------------------------------------
  Future<void> generarRecordatoriosPautados({
    required String uid,
    required String titulo,
    required String dosis,
    required String via,
    required String hora,
    required List<String> dias,
    required int frecuenciaHoras,
    required int? duracionDias,
  }) async {
    await FirebaseFirestore.instance.collection('medicamentos').add({
      'uid': uid,
      'titulo': titulo,
      'dosis': dosis,
      'via': via,
      'hora': hora,
      'dias': dias,
      'tipo': 'medicacion',
      'frecuencia_horas': frecuenciaHoras,
      'duracion_dias': duracionDias,
      'activo': true,
    });
  }

  // -----------------------------------------------------------
  // Auxiliar
  // -----------------------------------------------------------
  String _diaSemanaTexto(int n) {
    const dias = [
      "Lunes",
      "Martes",
      "Miércoles",
      "Jueves",
      "Viernes",
      "Sábado",
      "Domingo"
    ];
    return dias[n - 1];
  }
}
