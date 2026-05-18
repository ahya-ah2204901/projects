import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/method_constants.dart';
import 'package:yala_pay/providers/title_provider.dart';
import 'package:yala_pay/providers/user_provider.dart';
import 'package:yala_pay/routes/app_router.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "    ${titleProvider}",
          style: const TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic),
        )),
        toolbarHeight: 68.0,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => profilePopUp(context));
            },
            icon: const Icon(CupertinoIcons.profile_circled),
            color: accentColor,
            iconSize: 35,
          )
        ],
      ),
      floatingActionButton: _getFloatingActionButton(),
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: secondaryColor,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            switch (index) {
              case 0:
                context.goNamed(AppRouter.dashboard.name);
                titleNotifier.setTitle("YalaPay");
                break;
              case 1:
                context.goNamed(AppRouter.customers.name);
                titleNotifier.setTitle("Customers");
                break;
              case 2:
                context.goNamed(AppRouter.invoices.name);
                titleNotifier.setTitle("Invoices");
                break;
              case 3:
                context.goNamed(AppRouter.cheques.name);
                titleNotifier.setTitle("Cheques");
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.home,
                size: 30,
              ),
              label: "DashBoard",
            ),
            BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.person_2,
                  size: 30,
                ),
                label: "Customers"),
            BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.rectangle_dock,
                  size: 30,
                ),
                label: "Invoices"),
            BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.money_dollar,
                  size: 30,
                ),
                label: "Cheques")
          ]),
    );
  }

  Widget? _getFloatingActionButton() {
    switch (_selectedIndex) {
      case 1:
        return FloatingActionButton(
          backgroundColor: secondaryColor,
          focusColor: Colors.grey,
          onPressed: () {
            context.pushNamed(AppRouter.customerAddUpdate.name,
                pathParameters: {'customerId': '-1'});
          },
          child: const Icon(
            Icons.person_add,
            color: Colors.white,
          ),
        );
      case 2:
        return FloatingActionButton(
          backgroundColor: secondaryColor,
          focusColor: Colors.grey,
          onPressed: () {
            context.pushNamed(AppRouter.invoiceAddUpdate.name,
                pathParameters: {'invoiceId': '-1'});
          },
          child: const Icon(
            CupertinoIcons.add,
            color: Colors.white,
          ),
        );
      case 3:
        return FloatingActionButton(
          backgroundColor: secondaryColor,
          focusColor: Colors.grey,
          onPressed: () {
            context.pushNamed(AppRouter.chequeDepositAdd.name,
                pathParameters: {'chequeDepId': '-1'});
          },
          child: const Icon(
            CupertinoIcons.add,
            color: Colors.white,
          ),
        );
      default:
        return null;
    }
  }

  Widget profilePopUp(context) {
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
              SizedBox(
                height: screenSize.width * 0.1,
              ),
              Text(
                "${user?.displayName}",
                style: const TextStyle(
                    fontSize: 20, letterSpacing: 0.5, color: Colors.black87),
              ),
              Text(
                user?.email ?? '',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Colors.black87),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: const Text(
                  "Log Out",
                  style: TextStyle(
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white),
                ),
                onPressed: () {
                  ref.read(userNotifierProvider.notifier).signOut();
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
