import 'package:accelaid/providers/repo_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProvider extends Notifier<User?> {
  late final userRepo;

  @override
  build() {
    userRepo = ref.read(usersRepoProvider);
    userRepo.initialize();
    return null;
  }

  Future<User?> signIn(
      {required String email, required String password}) async {
    state = await userRepo.signIn(email: email, password: password);
    return state;
  }

  Future<User?> signUp(
      {required String email,
      required String password,
      required String fullName}) async {
    state = await userRepo.signUp(
        email: email, password: password, fullName: fullName);
    return state;
  }

  Future<void> signOut() async {
    userRepo.signOut();
    state = null;
  }

  Future<User?> getCurrentUser() async {
    state = await userRepo.getCurrentUser();
    return state;
  }
}

final userNotifierProvider =
    NotifierProvider<UserProvider, User?>(() => UserProvider());
