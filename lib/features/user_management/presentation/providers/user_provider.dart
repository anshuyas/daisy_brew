import 'package:daisy_brew/features/user_management/domain/entities/user_entity.dart';
import 'package:daisy_brew/features/user_management/domain/usecases/create_user_usecase.dart';
import 'package:daisy_brew/features/user_management/domain/usecases/delete_user_usecase.dart';
import 'package:daisy_brew/features/user_management/domain/usecases/get_users_usecase.dart';
import 'package:daisy_brew/features/user_management/domain/usecases/update_user_role_usecase.dart';
import 'package:daisy_brew/features/user_management/domain/usecases/update_userdetail_usecase.dart';
import 'package:daisy_brew/features/user_management/presentation/providers/user_usecase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final userProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<List<UserEntity>>>(
      (ref) => UserNotifier(
        getUsersUseCase: ref.watch(getUsersUseCaseProvider),
        updateUserRoleUseCase: ref.watch(updateUserRoleUseCaseProvider),
        deleteUserUseCase: ref.watch(deleteUserUseCaseProvider),
        createUserUseCase: ref.watch(createUserUseCaseProvider),
        updateUserDetailsUseCase: ref.watch(updateUserDetailsUseCaseProvider),
        ref: ref,
      ),
    );

class UserNotifier extends StateNotifier<AsyncValue<List<UserEntity>>> {
  final GetUsersUseCase getUsersUseCase;
  final UpdateUserRoleUseCase updateUserRoleUseCase;
  final DeleteUserUseCase deleteUserUseCase;
  final CreateUserUseCase createUserUseCase;
  final UpdateUserDetailsUseCase updateUserDetailsUseCase;
  final Ref ref;

  UserNotifier({
    required this.getUsersUseCase,
    required this.updateUserRoleUseCase,
    required this.deleteUserUseCase,
    required this.createUserUseCase,
    required this.updateUserDetailsUseCase,
    required this.ref,
  }) : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final users = await getUsersUseCase();
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateRole(String userId, String newRole) async {
    await updateUserRoleUseCase(userId: userId, newRole: newRole);
    await loadUsers();
  }

  Future<void> deleteUser(String userId) async {
    await deleteUserUseCase(userId: userId);
    await loadUsers();
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final newUser = await createUserUseCase(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      state = state.whenData((users) => [...users, newUser]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateUserDetails({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      await updateUserDetailsUseCase(userId: userId, name: name, email: email);

      // Update local state
      state = state.whenData(
        (users) => users
            .map(
              (u) => u.id == userId ? u.copyWith(name: name, email: email) : u,
            )
            .toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
