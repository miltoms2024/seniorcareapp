import 'package:flutter/material.dart';
import 'dart:async';

class TimeWidget extends StatefulWidget {
  const TimeWidget({super.key});

  @override
  State<TimeWidget> createState() => _TimeWidgetState();
}

class _TimeWidgetState extends State<TimeWidget> {
  late String _timeString;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timeString = _formatTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _timeString = _formatTime(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.access_time, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hora', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(_timeString, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
