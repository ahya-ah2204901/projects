import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workerapp/models/user.dart';
import 'package:workerapp/providers/repo_provider.dart';
import 'package:workerapp/repositories/user_repo.dart';

class RegistrationValidationResult {
  const RegistrationValidationResult({
    required this.isValid,
    this.errorMessage,
    this.supervisorId,
  });

  final bool isValid;
  final String? errorMessage;
  final String? supervisorId;
}

class UserNotifier extends AsyncNotifier<List<User>> {
  late final UserRepo _userRepo;

  @override
  Future<List<User>> build() async {
    _userRepo = await ref.watch(userRepoProvider.future);
    await _userRepo.initializeUsers();
    _userRepo
        .observeUsers()
        .listen((users) {
          state = AsyncValue.data(users);
        })
        .onError((e) {
          print('Error building user provider: $e');
        });
    return [];
  }

  Stream<List<User>> observeUsers() {
    return _userRepo.observeUsers();
  }

  // Stream<List<User>> getWorkers(String supervisorId) {
  //   return _userRepo.getWorkers(supervisorId);
  // }

  Future<User> getUserFromEmail(String email) async {
    return _userRepo.getUserFromEmail(email);
  }

  Future<bool> isExistingUser(String email) async {
    return _userRepo.isExistingUser(email);
  }

  bool isValidPassword(String password) {
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    return password.length >= 6 && hasLetters && hasNumbers;
  }

  Future<RegistrationValidationResult> validateRegistration({
    required String email,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
    required String? role,
    required String supervisorEmail,
  }) async {
    if (email.trim().isEmpty ||
        password.trim().isEmpty ||
        passwordConfirm.trim().isEmpty ||
        firstName.trim().isEmpty ||
        lastName.trim().isEmpty ||
        role == null ||
        role.isEmpty ||
        (role == 'Worker' && supervisorEmail.trim().isEmpty)) {
      return const RegistrationValidationResult(
        isValid: false,
        errorMessage: 'Fill all fields.',
      );
    }

    final isValidEmail =
        email.endsWith('@gmail.com') &&
        email.length > 12 &&
        !(await _userRepo.isExistingUser(email));
    final isValidPass = isValidPassword(password);

    if (password != passwordConfirm) {
      return const RegistrationValidationResult(
        isValid: false,
        errorMessage: 'Passwords do not match.',
      );
    }

    if (!isValidEmail && !isValidPass) {
      return const RegistrationValidationResult(
        isValid: false,
        errorMessage:
            'Invalid email and password.\nPassword must be at least 6 alphanumerical characters.',
      );
    }

    if (!isValidEmail || !isValidPass) {
      return RegistrationValidationResult(
        isValid: false,
        errorMessage: !isValidEmail
            ? 'Invalid email.'
            : 'Invalid password.\nPassword must be at least 6 alphanumerical characters.',
      );
    }

    if (role == 'Worker') {
      final supervisor = await _userRepo.getSupervisorByEmail(supervisorEmail);

      if (supervisor == null) {
        return const RegistrationValidationResult(
          isValid: false,
          errorMessage:
              'Invalid supervisor email.\nEnter an existing supervisor email.',
        );
      }

      return RegistrationValidationResult(
        isValid: true,
        supervisorId: supervisor.id,
      );
    }

    return const RegistrationValidationResult(isValid: true);
  }

  bool isExistingSupervisor(String email, List<User> allUsers) {
    return allUsers.any(
      (user) =>
          user.email.toLowerCase() == email.toLowerCase() &&
          user.role.toLowerCase() == 'supervisor',
    );
  }

  bool isExistingEmail(String email, List<User> allUsers) {
    return allUsers.any(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
    );
  }

  User? getUserById(String uid, List<User> users) {
    try {
      return users.firstWhere((u) => u.id == uid);
    } catch (_) {
      return null;
    }
  }

  User? getUserByEmail(String email, List<User> users) {
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }

  Stream<List<User>> getWorkersForSupervisor(String supervisorId) {
    return _userRepo.getWorkersForSupervisor(supervisorId);
  }

  Future<void> saveFcmToken(String userId, String token) async {
    final userRepo = await ref.read(userRepoProvider.future);
    await userRepo.saveFcmToken(userId, token);
  }

  Future<void> saveCurrentFcmToken(String userId) async {
    final userRepo = await ref.read(userRepoProvider.future);
    final token = await userRepo.getFcmToken();
    if (token == null) return;

    await userRepo.saveFcmToken(userId, token);
  }

  Future<void> watchFcmTokenRefresh(String userId) async {
    final userRepo = await ref.read(userRepoProvider.future);
    userRepo.onFcmTokenRefresh().listen((newToken) async {
      await userRepo.saveFcmToken(userId, newToken);
    });
  }

  Future<void> initNotifications() async {
    final userRepo = await ref.read(userRepoProvider.future);
    await userRepo.initNotifications();
  }

  Stream<Map<String, dynamic>?> observeLatestPrediction(String workerId) {
    return _userRepo.observeLatestPrediction(workerId);
  }
}

final userNotifierProvider = AsyncNotifierProvider<UserNotifier, List<User>>(
  () => UserNotifier(),
);

final workersForSupervisorProvider = StreamProvider.family<List<User>, String>((
  ref,
  supervisorId,
) async* {
  final userRepo = await ref.watch(userRepoProvider.future);
  await userRepo.initializeUsers();
  yield* userRepo.getWorkersForSupervisor(supervisorId);
});

final latestPredictionProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((
      ref,
      workerId,
    ) async* {
      final userRepo = await ref.watch(userRepoProvider.future);
      yield* userRepo.observeLatestPrediction(workerId);
    });
