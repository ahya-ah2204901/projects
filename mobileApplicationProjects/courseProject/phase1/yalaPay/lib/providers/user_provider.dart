import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/models/user.dart';
import 'package:yala_pay/repositories/yalaPay_app_repo.dart';

class UserProvider extends Notifier<List<User>> {
  final _appRepo = AppRepo();
  List<User> _users = [];
  late User loggedIn;

  @override
  build() {
    initializeUsers();
    return [];
  }

  void initializeUsers() async {
    _users = await _appRepo.loadUsers();
    state = _users;
  }

  setLoggedIn(User user) => loggedIn = user;
  getLoggedIn() => loggedIn;
}

final userNotifierProvider =
    NotifierProvider<UserProvider, List<User>>(() => UserProvider());
