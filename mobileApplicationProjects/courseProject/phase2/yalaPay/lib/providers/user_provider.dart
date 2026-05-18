import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/providers/repo_provider.dart';
import 'package:yala_pay/repositories/user_repo.dart';

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

  void signOut() => userRepo.signOut();

  Future<User?> getCurrentUser() async => await userRepo.getCurrentUser();
}

final userNotifierProvider =
    NotifierProvider<UserProvider, User?>(() => UserProvider());
