import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickavenue_clone/components/checkout/address_bottom_sheet.dart';
import 'package:kickavenue_clone/components/checkout/payment_bottom_sheet.dart';
import 'package:kickavenue_clone/helper/currency.dart';
import 'package:kickavenue_clone/helper/general.dart';
import 'package:kickavenue_clone/interface/product.dart';
import 'package:kickavenue_clone/provider/couriers.dart';
import 'package:kickavenue_clone/provider/default_shipping.dart';
import 'package:kickavenue_clone/provider/eta_text.dart';

import '../api/dio.dart';
import '../provider/user.dart';

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
  int shippingFee = 0;
  Map<String, dynamic> selectedAddress = {};
  bool isFullWallet = false;
  bool useKickPoint = false;

  bool submittingPayment = false;

  var txt = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      currentProduct = Availables.fromJson(widget.product);
      price = currentProduct!.asking_price
          .substring(0, currentProduct!.asking_price.length - 3);
      txt.text = currentProduct!.asking_price
          .substring(0, currentProduct!.asking_price.length - 3);
    });
  }

  Future<bool> pay() async {
    try {
      setState(() {
        submittingPayment = true;
      });
      final provinceResult = await Api()
          .request('postalcode/province?country=${selectedAddress['country']}');
      final List<dynamic> provinceList = provinceResult['data'].toList();

      final citiesResult = await Api().request(
          'postalcode/city?province=${selectedAddress['province']}&country=${selectedAddress['country']}');
      final List<dynamic> cityList = citiesResult['data'].toList();

      final provinceId = provinceList.firstWhere((element) {
        return element['name'] == selectedAddress['province'];
      })['id'];
      final cityId = cityList.firstWhere((element) {
        return element['name'] == selectedAddress['city'];
      })['id'];

      String endpointUri = '';

      final shippingPayload = {
        'id': selectedAddress['id'],
        'alias': selectedAddress['alias'],
        'full_name': selectedAddress['full_name'],
        'phone_number': selectedAddress['phone_number'],
        'street_address': selectedAddress['street_address'],
        'note': selectedAddress['note'],
        'country': selectedAddress['country'],
        'province': selectedAddress['province'],
        'province_id': provinceList.isNotEmpty ? provinceId : 0,
        'city': selectedAddress['city'],
        'city_id': citiesResult.isNotEmpty ? cityId : 0,
        'postal_code': selectedAddress['postal_code'],
      };
      final currentUser = ref.read(userDataProvider);
      final kickCredit = int.parse(currentUser['balance']
          .substring(0, currentUser['balance'].length - 3));
      final sellerCredit = int.parse(currentUser['balance_with_fee']
          .substring(0, currentUser['balance_with_fee'].length - 3));
      final kickPoint = int.parse(currentUser['locked_balance']
          .substring(0, currentUser['locked_balance'].length - 3));
      final totalWalletWithoutKickPoint = kickCredit + sellerCredit;

      int totalWalletUsage =
          isFullWallet ? totalWalletWithoutKickPoint + shippingFee : 0;

      if (useKickPoint) {
        totalWalletUsage += kickPoint;
      }

      final buyNowPayload = {
        'administration_fee': 0,
        'currency': 'IDR',
        'facebook_ad_campaign': null,
        'ka_courier_option': 'FLAT_RATE',
        'ka_courier_price': shippingFee,
        'offer_amount': int.parse(price),
        'payment_method': payment['payment_method'],
        'point_enabled': useKickPoint,
        'quantity': 1,
        'shipping': shippingPayload,
        'subsidy_price': 0,
        'unique_amount': 0,
        'user_sell_id': currentProduct!.id,
        'wallet_amount': totalWalletUsage,
      };

      final makeOfferPayload = {
        'shipping_id': shippingPayload['id'],
        'shipping': shippingPayload,
        'product_variant_id': currentProduct!.product_variant_id,
        'size_id': currentProduct!.size_id,
        'payment_method': payment['payment_method'],
        'amount': int.parse(price),
        'ka_courier_price': shippingFee,
        'administration_fee': 0,
        'user_sell_id': currentProduct!.id,
        'point_enabled': useKickPoint,
      };

      switch (buyNowPayload['payment_method']) {
        case VIRTUALACCOUNT:
          endpointUri = 'users/payments/xendit';
          break;
        case CREDITCARD:
        case BCA_INSTALLMENTS:
        case BCA_VA:
        case BRI_VA:
        case PERMATA_VA:
        case BNI_VA:
        case MANDIRI_VA:
        case MANDIRI_CREDIT_CARD:
        case GOPAY:
          endpointUri = 'users/payments/midtrans';
          break;
        case KREDIVO:
          endpointUri = 'users/payments/kredivo';
          break;
        case AKULAKU:
          endpointUri = 'users/payments/akulaku';
          break;
        case ATOME:
          endpointUri = 'users/payments/atome';
          break;
        case FULLWALLET:
        default:
          endpointUri = 'users/payments';
          break;
      }

      final result = await Api().post(endpointUri, buyNowPayload);
      print(result);

      setState(() {
        submittingPayment = false;
      });

      if (context.mounted) {
        context.pushNamed("payment", params: {
          'invoice': '',
        });
      }

      return true;
    } catch (e) {
      print(e);
      setState(() {
        submittingPayment = false;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue etaTexts = ref.watch(etaProvider);
    AsyncValue defaultShipping = ref.watch(defaultShippingProvider);
    Map<String, dynamic> userInfo = ref.watch(userDataProvider);

    selectedAddress = defaultShipping.maybeWhen(
        data: (value) => value,
        orElse: () => {
              'id': null,
              'alias': null,
              'full_name': null,
              'phone_number': null,
              'street_address': null,
              'note': null,
              'country': null,
              'province': null,
              'province_id': null,
              'city': null,
              'city_id': null,
              'postal_code': null,
            });

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
    this.shippingFee = shippingFee;

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
        price != '0' &&
        !submittingPayment;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      bottomSheet: Container(
        height: 50,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20, left: 25, right: 25),
        child: ElevatedButton(
          onPressed: enabledButton ? pay : null,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          child: !submittingPayment
              ? const Text('Pay Now')
              : const CircularProgressIndicator(
                  color: Colors.white,
                ),
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
                            price = lowestAsk.toString();
                            txt.text = lowestAsk.toString();
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
                controller: txt,
                enabled: isBuyNow ? false : true,
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
                    if (payment!['payment_method'] == FULLWALLET) {
                      isFullWallet = true;
                    } else {
                      isFullWallet = false;
                    }
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
            payment.isNotEmpty && payment['payment_method'] == FULLWALLET
                ? Container(
                    margin: const EdgeInsets.only(left: 25, right: 15, top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 250,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Use Kick points',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                  'Kick Credit: Rp ${formatCurrency.format(int.parse(userInfo['balance'].substring(0, userInfo['balance'].length - 3)))}'),
                              Text(
                                  'Kick Point: Rp ${formatCurrency.format(int.parse(userInfo['locked_balance'].substring(0, userInfo['locked_balance'].length - 3)))}'),
                            ],
                          ),
                        ),
                        Switch(
                          // This bool value toggles the switch.
                          value: useKickPoint,
                          activeColor: Colors.blue,
                          onChanged: (bool value) {
                            // This is called when the user toggles the switch.
                            setState(() {
                              useKickPoint = value;
                            });
                          },
                        ),
                      ],
                    ),
                  )
                : Container(),
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
