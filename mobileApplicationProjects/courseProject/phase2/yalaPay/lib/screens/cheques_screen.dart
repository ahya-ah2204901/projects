import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/cheque_deposit.dart';
import 'package:yala_pay/models/method_constants.dart';
import 'package:yala_pay/providers/cheque_deposit_provider.dart';
import 'package:yala_pay/providers/cheque_deposit_search_provider.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/routes/app_router.dart';
import 'package:yala_pay/widgets/cheque_deposit_tile.dart';

class ChequesScreen extends ConsumerStatefulWidget {
  const ChequesScreen({super.key});

  @override
  ConsumerState<ChequesScreen> createState() => _ChequesScreenState();
}

class _ChequesScreenState extends ConsumerState<ChequesScreen> {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final cheques = ref.watch(chequeNotifierProvider);
    final chequedeps = ref.watch(chequeDepositNotifierProvider);
    final searchProvider = ref.watch(chequeDepositSearchNotifierProvider);
    final chequeDeposits = ref.watch(chequeDepositNotifierProvider.future);
    final chequeDepositNotifier =
        ref.read(chequeDepositNotifierProvider.notifier);
    final searchNotifier =
        ref.read(chequeDepositSearchNotifierProvider.notifier);
   
    
    final isSearchEmpty = searchProvider.isEmpty;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: searchProvider,
                  decoration: InputDecoration(
                      prefixIconColor: primaryColor,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(
                        Icons.search,
                      ),
                      hintText: "Search",
                      labelText: "Search Cheque Deposits"),
                  onChanged: (s) {
                    searchNotifier.setSearch(s);
                    //chequeDepositNotifier.searchChequeDeposits(s);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: 80,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          elevation: 3,
                          fixedSize: const Size(10.0, 30.0),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text(
                        "Report",
                        style: TextStyle(
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.white),
                      ),
                      onPressed: () => context.pushNamed(
                            AppRouter.chequeReport.name,
                          )),
                ),
              ),
            ],
          ),
          Expanded(
            child: isSearchEmpty? 
            FutureBuilder<List<ChequeDeposit>>(
                  future: chequeDeposits, 
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final deposits = snapshot.data!;
                      if (deposits.isEmpty) {
                        return Center(child: Text('No cheque deposits available.'));
                      }
                      return ListView.builder(
                        itemCount: deposits.length,
                        itemBuilder: (BuildContext context, int index) {
                          final chequeDeposit = deposits[index];
                          return ChequeDepositTile(chequeDeposit: chequeDeposit);
                        },
                      );
                    } else {
                      return Center(child: Text('No data available.'));
                    }
                  },
                ) :
                StreamBuilder<List<ChequeDeposit>>(
                  stream: chequeDepositNotifier.searchChequeDeposits(searchProvider),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final deposits = snapshot.data!;
                      if (deposits.isEmpty) {
                        return Center(child: Text('No cheque deposits available.'));
                      }
                      return ListView.builder(
                        itemCount: deposits.length,
                        itemBuilder: (BuildContext context, int index) {
                          final chequeDeposit = deposits[index];
                          return ChequeDepositTile(chequeDeposit: chequeDeposit);
                        },
                      );
                    } else {
                      return Center(child: Text('No data available.'));
                    }
                  },
                )
          ),
        ],
      ),
    );
  }
}
