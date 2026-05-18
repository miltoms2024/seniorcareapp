import 'package:cloud_firestore/cloud_firestore.dart';

class Recordatorio {
  final String id;
  final String uid;
  final String titulo;
  final String hora;
  final List<String> dias;
  final String tipo; // "medicacion"
  final bool activo;

  // Campos opcionales
  final int? frecuenciaHoras;
  final int? duracionDias;
  final String? fechaInicio;
  final String? fechaFin;
  final String? via;
  final String? dosis; // ⭐ NECESARIO PARA TU APP

  Recordatorio({
    required this.id,
    required this.uid,
    required this.titulo,
    required this.hora,
    required this.dias,
    required this.tipo,
    required this.activo,
    this.frecuenciaHoras,
    this.duracionDias,
    this.fechaInicio,
    this.fechaFin,
    this.via,
    this.dosis,
  });

  factory Recordatorio.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Recordatorio(
      id: doc.id,
      uid: data['uid'] ?? '',
      titulo: data['titulo'] ?? '',
      hora: data['hora'] ?? '00:00',
      dias: List<String>.from(data['dias'] ?? []),
      tipo: data['tipo'] ?? '',
      activo: data['activo'] ?? true,
      frecuenciaHoras: data['frecuencia_horas'],
      duracionDias: data['duracion_dias'],
      fechaInicio: data['fecha_inicio'],
      fechaFin: data['fecha_fin'],
      via: data['via'],
      dosis: data['dosis'], // ⭐ AHORA SÍ EXISTE
    );
  }

  /// Convierte la hora "HH:mm" en DateTime del día actual
  DateTime get horaDateTime {
    final partes = hora.split(':');
    final h = int.tryParse(partes[0]) ?? 0;
    final m = int.tryParse(partes[1]) ?? 0;

    final ahora = DateTime.now();
    return DateTime(ahora.year, ahora.month, ahora.day, h, m);
  }
}