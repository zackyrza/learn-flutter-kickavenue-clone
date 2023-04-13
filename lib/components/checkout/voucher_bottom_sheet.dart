import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickavenue_clone/provider/voucher.dart';

class VoucherBottomSheet extends ConsumerStatefulWidget {
  const VoucherBottomSheet({super.key});

  @override
  ConsumerState<VoucherBottomSheet> createState() => _VoucherBottomSheetState();
}

class _VoucherBottomSheetState extends ConsumerState<VoucherBottomSheet> {
  String voucherText = '';
  TextEditingController txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AsyncValue vouchers = ref.watch(voucherProvider);
    return Container(
      height: 400,
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: txtController,
                    decoration: const InputDecoration(
                      hintText: 'Enter voucher code',
                    ),
                    onChanged: (value) {
                      setState(() {
                        voucherText = value;
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        voucherText = value;
                      });
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: vouchers.when(
              data: (data) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(data[index]['voucher']['name'] ?? ''),
                      subtitle: Text(data[index]['voucher']['code']),
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
            ),
          ),
        ],
      ),
    );
  }
}
