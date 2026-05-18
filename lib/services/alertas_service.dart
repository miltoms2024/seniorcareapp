import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AlertasService {
  static final FlutterLocalNotificationsPlugin _notificaciones =
      FlutterLocalNotificationsPlugin();

  // -----------------------------------------------------------
  // Inicializar notificaciones
  // -----------------------------------------------------------
  static Future<void> inicializar() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Madrid'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _notificaciones.initialize(settings);
  }

  // -----------------------------------------------------------
  // Cancelar todas las notificaciones
  // -----------------------------------------------------------
  static Future<void> cancelarTodas() async {
    await _notificaciones.cancelAll();
  }

  // -----------------------------------------------------------
  // Programar una única alerta (próximo recordatorio)
  // -----------------------------------------------------------
  static Future<void> programarAlerta({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fecha,
  }) async {
    final android = AndroidNotificationDetails(
      'canal_recordatorios',
      'Recordatorios',
      channelDescription: 'Notificaciones de recordatorios',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    final ios = DarwinNotificationDetails();

    final detalles = NotificationDetails(
      android: android,
      iOS: ios,
    );

    // CORRECCIÓN PROFESIONAL: no se puede reasignar "fecha"
    final ahora = DateTime.now();
    DateTime fechaProgramada = fecha;

    if (fechaProgramada.isBefore(ahora)) {
      fechaProgramada = fechaProgramada.add(const Duration(days: 1));
    }

    final tzFecha = tz.TZDateTime(
      tz.local,
      fechaProgramada.year,
      fechaProgramada.month,
      fechaProgramada.day,
      fechaProgramada.hour,
      fechaProgramada.minute,
    );

    await _notificaciones.zonedSchedule(
      id,
      titulo,
      cuerpo,
      tzFecha,
      detalles,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repetición diaria
    );
  }
}
