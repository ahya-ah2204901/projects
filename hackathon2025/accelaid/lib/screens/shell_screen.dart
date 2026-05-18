import 'package:accelaid/models/color_const.dart';
import 'package:accelaid/providers/teacher_provider.dart';
import 'package:accelaid/providers/title_provider.dart';
import 'package:accelaid/providers/user_provider.dart';
import 'package:accelaid/routes/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShellScreen extends ConsumerStatefulWidget {
  final Widget? body;
  const ShellScreen({super.key, this.body});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  @override
  Widget build(BuildContext context) {
    final titleProvider = ref.watch(titleNotifierProvider);
    final titleNotifier = ref.read(titleNotifierProvider.notifier);
    final teacherprovider = ref.watch(teacherNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titleProvider,
          style: TextStyle(
            fontSize: 23,
            color: darkblue,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/layout/drawer_header.png'),
                    fit: BoxFit.fitWidth,
                  ),
                  color: darkblue),
              child: teacherprovider.when(
                data: (teacher) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: darkblue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Ready to Accelerate?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        teacher!.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home_rounded, color: lightblue),
              title: Text('Home', style: TextStyle(color: darkblue)),
              onTap: () {
                context.pop();
                titleNotifier.setTitle('AccelAid');
                context.goNamed(AppRouter.dashboard.name);
              },
            ),
            const Divider(height: 1, color: Colors.grey),
            ListTile(
              leading: Icon(Icons.people_alt_outlined, color: lightblue),
              title: Text('All Students', style: TextStyle(color: darkblue)),
              onTap: () {
                context.pop();
                titleNotifier.setTitle('All Students');
                context.goNamed(AppRouter.allStudents.name);
              },
            ),
            ListTile(
              leading: Icon(Icons.people_alt, color: lightblue),
              title:
                  Text('Students by Grade', style: TextStyle(color: darkblue)),
              onTap: () {
                context.pop();
                titleNotifier.setTitle('');
                context.goNamed(AppRouter.gradelevels.name);
              },
            ),
            ListTile(
              leading: Icon(Icons.assessment_outlined, color: lightblue),
              title: Text('Competency Exam', style: TextStyle(color: darkblue)),
              onTap: () {
                context.pop();
                titleNotifier.setTitle('');
                context.goNamed(AppRouter.generateCompExam.name);
              },
            ),
            const Divider(height: 1, color: Colors.grey),
            const Spacer(),
            ListTile(
              leading: Icon(Icons.logout, color: lightblue),
              title: Text('Log Out', style: TextStyle(color: darkblue)),
              onTap: () {
                User? userprov = ref.watch(userNotifierProvider);
                print(userprov!.email);
                print(userprov.displayName);

                ref.read(titleNotifierProvider.notifier).setTitle('AccelAid');
                ref.read(userNotifierProvider.notifier).signOut();

                print(userprov!.email);
                print(userprov.displayName);

                context.goNamed(AppRouter.login.name);
              },
            ),
          ],
        ),
      ),
      body: widget.body ?? const Center(child: Text('Body Content')),
      floatingActionButton: _getFloatingActionButton(),
    );
  }

  Widget? _getFloatingActionButton() {
    final currentLocation =
        GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;

    if (currentLocation == AppRouter.allStudents.path) {
      return FloatingActionButton(
        onPressed: () {
          context.pushNamed(AppRouter.addStudent.name);
          print('FAB Pressed on Grade Levels Screen');
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: darkblue,
      );
    }

    return null;
  }
}
