import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workerapp/models/user.dart';
import 'package:workerapp/providers/auth_provider.dart';
import 'package:workerapp/providers/title_provider.dart';
import 'package:workerapp/providers/user_provider.dart';
import 'package:workerapp/routes/app_router.dart';

class ShellScreen extends ConsumerStatefulWidget {
  final Widget? body;
  const ShellScreen({super.key, this.body});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final titleProvider = ref.watch(titleNotifierProvider);
    final titleNotifier = ref.read(titleNotifierProvider.notifier);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final userNotifier = ref.read(userNotifierProvider.notifier);

    final authProvider = ref.watch(authNotifierProvider);
    final usersProvider = ref.watch(userNotifierProvider);

    final userId = fb.FirebaseAuth.instance.currentUser?.uid;
    final authUser = ref.watch(authNotifierProvider).value;
    final users = ref.watch(userNotifierProvider).value;

    if (authUser == null || users == null || userId == null)
      return CircularProgressIndicator();
    final loggedInUser = users.firstWhere((u) => u.id == authUser.uid);

    // if (userId == null) {
    //   return const Center(child: Text("Not logged in"));
    // }

    // //late final loggedInUser;
    // final authUser = ref.watch(authNotifierProvider).value;
    // final allUsers = ref.watch(userNotifierProvider).value;
    // final supervisorEmail = authUser?.email;
    // final loggedInUser = userNotifier.getUserByEmail(
    //   supervisorEmail!,
    //   allUsers!,
    // );

    return authProvider.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error loading auth: $e'))),
      data: (authUser) {
        if (authUser == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return usersProvider.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) =>
              Scaffold(body: Center(child: Text('Error loading users: $e'))),
          data: (allUsers) {
            final loggedInUser = userNotifier.getUserByEmail(
              authUser.email ?? '',
              allUsers,
            );

            if (loggedInUser == null) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ), //Text('User profile not found')),
              );
            }

            final isSupervisor =
                loggedInUser.role.toLowerCase() == 'supervisor';

            return Scaffold(
              appBar: AppBar(
                title: Center(
                  child: Text(
                    "       ${titleProvider}",
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
                toolbarHeight: 68.0,
                backgroundColor: const Color.fromARGB(255, 8, 21, 65),
                actions: [
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => profilePopUp(context),
                      );
                    },
                    icon: const Icon(CupertinoIcons.profile_circled),
                    color: const Color.fromARGB(255, 232, 235, 243),
                    iconSize: 35,
                  ),
                ],
              ),
              body: widget.body,
              bottomNavigationBar: isSupervisor
                  ? _buildSupervisorNavBar(titleNotifier, context)
                  : _buildWorkerNavBar(titleNotifier, context),
            );
          },
        );
      },
    );
  }

  BottomNavigationBar _buildSupervisorNavBar(
    TitleNotifier titleNotifier,
    BuildContext context,
  ) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: const Color.fromARGB(255, 70, 141, 222),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 0:
            context.goNamed(AppRouter.supervisorHome.name);
            titleNotifier.setTitle("STARX");
            break;
          case 1:
            context.goNamed(AppRouter.alerts.name);
            titleNotifier.setTitle("Alerts");
            break;
          case 2:
            context.goNamed(AppRouter.workers.name);
            titleNotifier.setTitle("Workers");
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home, size: 30),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.exclamationmark_bubble, size: 30),
          label: "Alerts",
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person_2, size: 30),
          label: "Workers",
        ),
      ],
    );
  }

  BottomNavigationBar _buildWorkerNavBar(
    TitleNotifier titleNotifier,
    BuildContext context,
  ) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: const Color.fromARGB(255, 70, 141, 222),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 0:
            context.goNamed(AppRouter.workerHome.name);
            titleNotifier.setTitle("STARX");
            break;
          case 1:
            context.goNamed(AppRouter.alerts.name);
            titleNotifier.setTitle("Alerts");
            break;
          case 2:
            context.goNamed(AppRouter.data.name);
            titleNotifier.setTitle("Readings");
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home, size: 30),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.exclamationmark_bubble, size: 30),
          label: "Alerts",
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.doc, size: 30),
          label: "Readings",
        ),
      ],
    );
  }

  Widget profilePopUp(context) {
    final authProvider = ref.watch(authNotifierProvider);
    final usersProvider = ref.watch(userNotifierProvider);

    final userId = fb.FirebaseAuth.instance.currentUser?.uid;
    final authUser = ref.watch(authNotifierProvider).value;
    final users = ref.watch(userNotifierProvider).value;

    if (authUser == null || users == null) return CircularProgressIndicator();
    final loggedInUser = users.firstWhere((u) => u.id == authUser.uid);

    if (userId == null) {
      return const Center(child: Text("Not logged in"));
    }
    var screenSize = MediaQuery.of(context).size;
    final user = ref.watch(userNotifierProvider);
    return AlertDialog(
      content: SizedBox(
        height: screenSize.height * 0.35,
        width: screenSize.width * 0.8,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                CupertinoIcons.profile_circled,
                color: Colors.black45,
                size: screenSize.height * 0.1,
              ),
              SizedBox(height: screenSize.width * 0.1),
              Text(
                "${loggedInUser.firstName} ${loggedInUser.lastName}",
                style: const TextStyle(
                  fontSize: 20,
                  letterSpacing: 0.5,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${loggedInUser.email}', //user?.email ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 24, 38, 84),
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Log Out",
                  style: TextStyle(
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).signOut();
                  GoRouter.of(context).goNamed(AppRouter.login.name);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
