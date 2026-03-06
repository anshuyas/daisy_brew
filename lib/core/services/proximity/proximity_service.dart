import 'dart:async';
import 'package:proximity_sensor/proximity_sensor.dart';
import '../../../app/theme/app_theme.dart';

class ProximityService {
  StreamSubscription<dynamic>? _subscription;
  DateTime? _lastTrigger;

  void startListening() {
    _subscription = ProximitySensor.events.listen((event) {
      if (event > 0) _toggleThemeWithCooldown();
    });
  }

  void _toggleThemeWithCooldown() {
    final now = DateTime.now();
    if (_lastTrigger != null && now.difference(_lastTrigger!).inSeconds < 2)
      return;

    _lastTrigger = now;
    AppTheme.isDarkMode.value = !AppTheme.isDarkMode.value;
  }

  void stopListening() {
    _subscription?.cancel();
  }
}

final proximityService = ProximityService();
