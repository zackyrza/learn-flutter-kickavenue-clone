import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helper/general.dart';

class PaymentMethodBottomSheet extends ConsumerStatefulWidget {
  const PaymentMethodBottomSheet({super.key});

  @override
  ConsumerState<PaymentMethodBottomSheet> createState() =>
      _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState
    extends ConsumerState<PaymentMethodBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      color: Colors.white,
      child: ListView.builder(
        itemCount: defaultPaymentMethod.length,
        itemBuilder: (context, index) {
          final paymentMethod = defaultPaymentMethod[index];
          return ListTile(
            title: Text(paymentMethod['label']),
            subtitle: Text(paymentMethod['payment_method']),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pop(context, paymentMethod);
            },
          );
        },
      ),
    );
  }
}
