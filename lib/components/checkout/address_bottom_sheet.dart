import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickavenue_clone/provider/shipping.dart';

class AddressBottomSheet extends ConsumerStatefulWidget {
  const AddressBottomSheet({super.key});

  @override
  ConsumerState<AddressBottomSheet> createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends ConsumerState<AddressBottomSheet> {
  @override
  Widget build(BuildContext context) {
    AsyncValue shipping = ref.watch(shippingProvider);
    return Container(
        height: 200,
        color: Colors.white,
        child: shipping.when(
          data: (data) {
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    '${data[index]['alias']} - ${data[index]['full_name']}',
                  ),
                  subtitle: Text(data[index]['street_address']),
                  onTap: () {
                    Navigator.pop(context, data[index]);
                  },
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Text(error.toString()),
        ));
  }
}
