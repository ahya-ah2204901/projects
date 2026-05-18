import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workerapp/providers/repo_provider.dart';
import 'package:workerapp/repositories/user_repo.dart';

class AuthNotifier extends AsyncNotifier<fb.User?> {
  late final UserRepo _userRepo;

  @override
  Future<fb.User?> build() async {
    _userRepo = await ref.watch(userRepoProvider.future);
    return _userRepo.getCurrentUser();
  }

  // Stream<List<User>> observeUsers() {
  //   return _userRepo.observeUsers();
  // }

  Future<fb.User?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? supervisorId,
  }) async {
    final user = await _userRepo.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      role: role,
      supervisorId: supervisorId,
    );
    state = AsyncValue.data(user);
    return user;
  }

  Future<void> resetPassword({required String email}) async {
    await _userRepo.resetPassword(email: email);
  }

  Future<void> resendVerificationEmail() async {
    await _userRepo.resendVerificationEmail();
  }

  Future<bool> checkEmailVerificationAndSignOut() async {
    final isVerified = await _userRepo.refreshEmailVerificationStatus();

    if (isVerified) {
      await signOut();
    }

    return isVerified;
  }

  Future<void> signOut() async {
    await _userRepo.signOut();
    state = const AsyncValue.data(null);
  }

  Future<fb.User?> getCurrentUser() async => await _userRepo.getCurrentUser();

  Future<String?> getCurrentUserId() async =>
      await _userRepo.getCurrentUserId();

  Future<fb.User?> signIn({
    required String email,
    required String password,
  }) async {
    final user = await _userRepo.signIn(email: email, password: password);
    state = AsyncValue.data(user);
    return user;
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, fb.User?>(
  () => AuthNotifier(),
);
