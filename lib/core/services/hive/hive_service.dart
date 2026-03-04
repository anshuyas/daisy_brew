import 'package:daisy_brew/core/constants/hive_table_constants.dart';
import 'package:daisy_brew/features/auth/data/models/auth_hive_model.dart';
import 'package:daisy_brew/features/dashboard/data/models/tea_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapter();
    await openBoxes();
  }

  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.teaProductTypeId)) {
      Hive.registerAdapter(TeaHiveModelAdapter());
    }
  }

  Future<void> openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    await Hive.openBox(
      HiveTableConstant.appSettingsTable,
    ); // For current_auth_id
    await Hive.openBox<TeaHiveModel>(HiveTableConstant.teaTable);
  }

  // Box getter for Tea products
  Box<TeaHiveModel> get _teaBox =>
      Hive.box<TeaHiveModel>(HiveTableConstant.teaTable);

  // --- Tea CRUD methods ---
  Future<List<TeaHiveModel>> getAllTeaProducts() async {
    return _teaBox.values.toList();
  }

  Future<void> addTeaProduct(TeaHiveModel tea) async {
    await _teaBox.put(tea.id, tea);
  }

  Future<void> updateTeaProduct(TeaHiveModel tea) async {
    await _teaBox.put(tea.id, tea);
  }

  Future<void> toggleTeaAvailability(String id) async {
    final tea = _teaBox.get(id);
    if (tea != null) {
      final updated = TeaHiveModel(
        id: tea.id,
        name: tea.name,
        image: tea.image,
        price: tea.price,
        isAvailable: !tea.isAvailable,
        category: tea.category,
      );
      await _teaBox.put(id, updated);
    }
  }

  Future<void> deleteTeaProduct(String id) async {
    await _teaBox.delete(id);
  }

  Future<void> close() async {
    await Hive.close();
  }

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);
  Box get _appBox => Hive.box(HiveTableConstant.appSettingsTable);

  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
    return model;
  }

  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      final user = users.first;
      await _appBox.put('current_auth_id', user.authId); // Set current user
      return user;
    }
    return null;
  }

  Future<void> logoutUser() async {
    await _appBox.delete('current_auth_id');
  }

  AuthHiveModel? getCurrentUser() {
    final currentId = _appBox.get('current_auth_id') as String?;
    if (currentId != null) {
      return _authBox.get(currentId);
    }
    return null;
  }

  bool isEmailExists(String email) {
    final users = _authBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }
}
