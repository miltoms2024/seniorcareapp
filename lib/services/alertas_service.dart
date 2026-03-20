import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AlertasService {
  static final FlutterLocalNotificationsPlugin _notificaciones =
      FlutterLocalNotificationsPlugin();

  /// Inicializar el sistema de notificaciones
  static Future<void> inicializar() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Madrid')); // 🔥 IMPORTANTE

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _notificaciones.initialize(settings);
  }

  /// Programar una notificación semanal por días y hora
  static Future<void> programarNotificacion({
    required String idRecordatorio,
    required String titulo,
    required String descripcion,
    required TimeOfDay hora,
    required List<String> dias,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'canal_recordatorios',
      'Recordatorios',
      channelDescription: 'Notificaciones de recordatorios',
      importance: Importance.max,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    for (final dia in dias) {
      final weekday = _convertirDia(dia);

      final now = tz.TZDateTime.now(tz.local);

      // 🔥 Convertimos correctamente a TZDateTime
      final fecha = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hora.hour,
        hora.minute,
      );

      final proxima = _proximaFecha(fecha, weekday);

      await _notificaciones.zonedSchedule(
        idRecordatorio.hashCode + weekday,
        titulo,
        descripcion,
        proxima,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Cancelar una notificación
  static Future<void> cancelarNotificacion(String idRecordatorio) async {
    await _notificaciones.cancel(idRecordatorio.hashCode);
  }

  /// Reprogramar una notificación (cancelar + crear)
  static Future<void> reprogramar({
    required String idRecordatorio,
    required String titulo,
    required String descripcion,
    required TimeOfDay hora,
    required List<String> dias,
  }) async {
    await cancelarNotificacion(idRecordatorio);
    await programarNotificacion(
      idRecordatorio: idRecordatorio,
      titulo: titulo,
      descripcion: descripcion,
      hora: hora,
      dias: dias,
    );
  }

  /// Convertir nombre de día a número de weekday
  static int _convertirDia(String dia) {
    switch (dia.toLowerCase()) {
      case 'lunes':
        return DateTime.monday;
      case 'martes':
        return DateTime.tuesday;
      case 'miércoles':
      case 'miercoles':
        return DateTime.wednesday;
      case 'jueves':
        return DateTime.thursday;
      case 'viernes':
        return DateTime.friday;
      case 'sábado':
      case 'sabado':
        return DateTime.saturday;
      case 'domingo':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }

  /// Calcular la próxima fecha válida para la notificación
  static tz.TZDateTime _proximaFecha(tz.TZDateTime fecha, int weekday) {
    var scheduled = fecha;
    final now = tz.TZDateTime.now(tz.local);

    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}