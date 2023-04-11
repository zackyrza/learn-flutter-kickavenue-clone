import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickavenue_clone/components/checkout/address_bottom_sheet.dart';
import 'package:kickavenue_clone/components/checkout/payment_bottom_sheet.dart';
import 'package:kickavenue_clone/helper/currency.dart';
import 'package:kickavenue_clone/helper/general.dart';
import 'package:kickavenue_clone/interface/product.dart';
import 'package:kickavenue_clone/provider/couriers.dart';
import 'package:kickavenue_clone/provider/default_shipping.dart';
import 'package:kickavenue_clone/provider/eta_text.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> product;

  const CheckoutPage({super.key, required this.product});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  Availables? currentProduct;
  bool isBuyNow = true;
  Map<String, dynamic> payment = {};
  String price = '0';

  @override
  void initState() {
    super.initState();
    setState(() {
      currentProduct = Availables.fromJson(widget.product);
    });
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue etaTexts = ref.watch(etaProvider);
    AsyncValue defaultShipping = ref.watch(defaultShippingProvider);
    ref.read(courierProvider.notifier).fetch(
        country: defaultShipping.value == null
            ? 'IDN'
            : defaultShipping.value['country'],
        province: defaultShipping.value == null
            ? 'Jawa Barat'
            : defaultShipping.value['province'],
        productPrice: int.parse(currentProduct!.asking_price
            .substring(0, currentProduct!.asking_price.length - 3)),
        productVariantId: currentProduct!.product_variant_id,
        weight: currentProduct!.product_variant['weight']);
    final shippingFee = ref.watch(courierProvider);

    final lowestAsk = currentProduct == null
        ? 0
        : int.parse(currentProduct!.asking_price
            .substring(0, currentProduct!.asking_price.length - 3));
    final highestOffer =
        currentProduct == null ? 0 : currentProduct!.highest_bid.amount;

    final boxConditions = boxCondition(currentProduct!.box_condition);
    final sneakerConditions =
        sneakersCondition(currentProduct!.sneakers_condition);
    final accesorriesConditions =
        accessoriesCondition(currentProduct!.missing_accessories);
    final yellowing = currentProduct!.yellowing ? 'Yellowing' : null;
    final sneakersDefect = currentProduct!.sneakers_defect ? 'Defect' : null;
    final displayItem = currentProduct!.display_item ? 'Display Item' : null;
    final etaText = estimatedTimeArrivals(
      currentProduct!.pre_verified,
      false,
      '',
      etaTexts.value ?? {},
    );

    final List generalCondition = [
      sneakerConditions,
      boxConditions,
      accesorriesConditions,
      yellowing,
      sneakersDefect,
      displayItem,
    ];
    final String productConditions = generalCondition
        .where((element) => element != null)
        .toList()
        .join(', ');

    final int amountToBePaid = shippingFee +
        int.parse(currentProduct!.asking_price
            .substring(0, currentProduct!.asking_price.length - 3)) -
        int.parse(currentProduct!.subsidy_price ??
            '0'.substring(
                0,
                currentProduct!.subsidy_price == null
                    ? 1
                    : currentProduct!.subsidy_price!.length - 3));

    final bool enabledButton = payment.isNotEmpty &&
        amountToBePaid > 0 &&
        defaultShipping.value != null &&
        price != '0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      bottomSheet: Container(
        height: 50,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20, left: 25, right: 25),
        child: ElevatedButton(
          onPressed: enabledButton ? () {} : null,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          child: const Text('Pay Now'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() {
                            isBuyNow = true;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: isBuyNow ? Colors.blue : Colors.white,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Buy Now',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isBuyNow ? Colors.white : Colors.black,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    'Lowest Ask',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isBuyNow
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    'Rp ${formatCurrency.format(lowestAsk)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isBuyNow
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() {
                            isBuyNow = false;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: isBuyNow == false
                                  ? Colors.blue
                                  : Colors.white,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Make Offer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isBuyNow == false
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    'Highest Offer',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isBuyNow == false
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    'Rp ${formatCurrency.format(highestOffer)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isBuyNow == false
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Place your price here..',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                ),
                onChanged: (value) => setState(() {
                  price = value;
                }),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Size',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentProduct!.size.US ?? '',
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Condition',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: Text(
                            productConditions,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 150,
                        child: Text(
                          'Estimated Time of Arrival',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          etaText,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: defaultShipping.when(
                data: (data) {
                  return InkWell(
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return const AddressBottomSheet();
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data == {}
                              ? 'Shipping Address'
                              : '${data['alias']} - ${data['full_name']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, s) => Text(e.toString()),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: InkWell(
                onTap: () async {
                  final paymentMethodValue =
                      await showModalBottomSheet<Map<String, dynamic>>(
                    context: context,
                    builder: (BuildContext context) {
                      return const PaymentMethodBottomSheet();
                    },
                  );
                  setState(() {
                    payment = paymentMethodValue ?? {};
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      payment.isEmpty ? 'Payment Method' : payment['label'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 150,
                    child: Text(
                      'Amount to be paid',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: Text(
                      formatCurrency.format(amountToBePaid),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
