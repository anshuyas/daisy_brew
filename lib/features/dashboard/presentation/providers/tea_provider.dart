// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:daisy_brew/features/dashboard/data/models/tea_hive_model.dart';
// import 'package:daisy_brew/core/services/hive/hive_service.dart';
// import 'package:flutter_riverpod/legacy.dart';

// // Provider for HiveService
// final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

// // Provider for the list of Tea products
// final teaProductsProvider =
//     StateNotifierProvider<TeaProductsNotifier, List<TeaHiveModel>>((ref) {
//       final hiveService = ref.read(hiveServiceProvider);
//       return TeaProductsNotifier(hiveService)..loadTeaProducts();
//     });

// class TeaProductsNotifier extends StateNotifier<List<TeaHiveModel>> {
//   final HiveService _hiveService;

//   TeaProductsNotifier(this._hiveService) : super([]);

//   Future<void> loadTeaProducts() async {
//     final teas = await _hiveService.getAllTeaProducts();
//     state = teas;
//   }

//   Future<void> addTeaProduct(TeaHiveModel tea) async {
//     await _hiveService.addTeaProduct(tea);
//     await loadTeaProducts();
//   }

//   Future<void> updateTeaProduct(TeaHiveModel tea) async {
//     await _hiveService.updateTeaProduct(tea);
//     await loadTeaProducts();
//   }

//   Future<void> toggleAvailability(TeaHiveModel tea) async {
//     await _hiveService.toggleTeaAvailability(tea.id);
//     await loadTeaProducts();
//   }

//   Future<void> deleteTeaProduct(TeaHiveModel tea) async {
//     await _hiveService.deleteTeaProduct(tea.id);
//     await loadTeaProducts();
//   }
// }
