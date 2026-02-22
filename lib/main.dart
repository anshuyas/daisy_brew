import 'package:daisy_brew/core/services/hive/hive_service.dart';
import 'package:daisy_brew/core/services/proximity/proximity_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hiveService = HiveService();
  await hiveService.init();
  final proximityService = ProximityService();
  proximityService.startListening();
  runApp(const ProviderScope(child: MyApp()));
}
