import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/method_constants.dart';
import 'package:yala_pay/widgets/comfirm_deletion_dialog.dart';

import '../models/customer.dart';
import '../providers/customer_provider.dart';
import '../routes/app_router.dart';

class CustomerTile extends ConsumerStatefulWidget {
  final Customer customer;
  const CustomerTile({super.key, required this.customer});

  @override
  ConsumerState<CustomerTile> createState() => _CustomerTileState();
}

class _CustomerTileState extends ConsumerState<CustomerTile> {
  @override
  Widget build(BuildContext context) {
    final customerNotifier = ref.read(customerNotifierProvider.notifier);
    var customer = widget.customer;
    return GestureDetector(
      onTap: () {
        context.pushNamed(AppRouter.customerDetails.name,
            pathParameters: {'customerId': customer.id});
      },
      child: Card(
        child: ListTile(
          leading: const Icon(
            Icons.person,
            size: 30,
          ),
          title: Text(
            customer.companyName,
            style: TextStyle(
                overflow: TextOverflow.ellipsis,
                fontSize: (customer.companyName.length > 21) ? 15 : 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${customer.address.city}, ${customer.address.country}"),
              Text(
                  "${customer.contactDetails.firstName} ${customer.contactDetails.lastName}",
                  style: const TextStyle(fontSize: 14)),
            ],
          ),
          trailing: IconButton(
              onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmDeletionDialog(
                        onDelete: () {
                          customerNotifier.deleteCustomer(customer);
                        },
                      );
                    },
                  ),
              icon: const Icon(
                CupertinoIcons.trash,
                size: 22,
              )),
        ),
      ),
    );
  }
}
