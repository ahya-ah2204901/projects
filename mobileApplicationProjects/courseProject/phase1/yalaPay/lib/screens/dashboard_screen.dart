import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/color_constants.dart';
import 'package:yala_pay/models/user.dart';
import 'package:yala_pay/providers/user_provider.dart';
import 'package:yala_pay/routes/app_router.dart';
import 'package:yala_pay/widgets/dashboard_swiper.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    User user = ref.read(userNotifierProvider.notifier).getLoggedIn();

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: screenSize.width,
            height: screenSize.height * 0.45,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: screenSize.width,
                  height: 100,
                  child: Padding(
                      padding:
                          const EdgeInsets.only(top: 25.0, right: 25, left: 35),
                      child: Text(
                        'Welcome back ${user.firstName} ${user.lastName}.\nSwipe your Summary to see what\nInvoices and Cheques you have missed.',
                        style: const TextStyle(
                            color: Color.fromARGB(191, 255, 255, 255),
                            fontSize: 15.5,
                            letterSpacing: 0.3,
                            wordSpacing: 0.4,
                            height: 1),
                      )),
                ),
                // this is the Swiper UI of the Summary Cards
                const SwiperBuilder(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30.0, bottom: 30),
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  reportButtonBuilder(
                      "Generate Invoice Report", AppRouter.invoicesReport.name),
                  reportButtonBuilder(
                      "Generate Cheque Report", AppRouter.chequeReport.name),
                  // Image.asset(
                  //   'assets/images/dashboard_cards/dashboard_chart.png',
                  //   height: 110,
                  // )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget reportButtonBuilder(String buttonText, var buttonRouteName) {
    var screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width,
      height: 100,
      child: Padding(
        padding:
            const EdgeInsets.only(top: 10.0, bottom: 10, right: 25, left: 25),
        child: ElevatedButton(
          onPressed: () {
            context.pushNamed(buttonRouteName);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              elevation: 3,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: Text(
            buttonText,
            style: const TextStyle(
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.white),
          ),
        ),
      ),
    );
  }
}
