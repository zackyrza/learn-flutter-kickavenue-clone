import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickavenue_clone/helper/currency.dart';
import 'package:kickavenue_clone/provider/is_logged_in.dart';

import '../../interface/product.dart';

class BrandNewBottomSheet extends ConsumerWidget {
  final List<Availables> list;

  const BrandNewBottomSheet({super.key, required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isLoggedIn = ref.watch(loginStatusProvider);
    return Container(
      height: 800,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 10),
            decoration: const BoxDecoration(
              border: BorderDirectional(
                bottom: BorderSide(
                  color: Colors.black,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Brand New Products'),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              border: BorderDirectional(
                bottom: BorderSide(
                  color: Color.fromARGB(66, 50, 27, 27),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Expanded(
                  child: Text(
                    'Price',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Size',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Highest Offer',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
                  final int price = int.parse(list[index]
                      .asking_price
                      .substring(0, list[index].asking_price.length - 3));
                  final String size = list[index].size.US ?? '-';
                  final int offer = list[index].highest_bid.amount;
                  return InkWell(
                    onTap: () {
                      if (isLoggedIn) {
                        context.pushNamed('checkout', params: {
                          'product': json.encode(list[index].toJson()),
                        });
                        return;
                      }
                      context.goNamed('login');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Rp ${formatCurrency.format(price)}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              size,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              offer == 0 ? '-' : formatCurrency.format(offer),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
