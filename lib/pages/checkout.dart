import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickavenue_clone/components/checkout/address_bottom_sheet.dart';
import 'package:kickavenue_clone/components/checkout/payment_bottom_sheet.dart';
import 'package:kickavenue_clone/components/checkout/promo_product_bottom_sheet.dart';
import 'package:kickavenue_clone/components/checkout/voucher_bottom_sheet.dart';
import 'package:kickavenue_clone/helper/currency.dart';
import 'package:kickavenue_clone/helper/general.dart';
import 'package:kickavenue_clone/interface/product.dart';
import 'package:kickavenue_clone/provider/couriers.dart';
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
  Map<String, dynamic> selectedAddress = {
    'id': null,
    'alias': null,
    'full_name': null,
    'phone_number': null,
    'street_address': null,
    'note': null,
    'country': 'IDN',
    'province': 'Jawa Barat',
    'province_id': null,
    'city': null,
    'city_id': null,
    'postal_code': null,
  };
  Map<String, dynamic> selectedVoucher = {
    'created_at': '',
    'ended_at': '',
    'id': '',
    'is_expired': false,
    'rank': 0,
    'started_at': '',
    'updated_at': '',
    'used': false,
    'used_at': null,
    'used_count': '0',
    'user_id': 0,
    'voucher_id': 0,
    'voucher': {
      'active': false,
      'amount': "0",
      'code': "",
      'created_at': '',
      'currency': '',
      'deduct_type': '',
      'description': '',
      'disposable_voucher': false,
      'enabled_payments': [],
      'ended_at': '',
      'group_name': null,
      'id': 0,
      'images': [],
      'instructions': '',
      'is_cashback': false,
      'is_expired': false,
      'limit': 0,
      'limit_per_user': 0,
      'listing_pre_order': false,
      'listing_pre_verified': false,
      'max_amount': '0',
      'minimum_purchase': '0',
      'name': '',
      'new_user_ended_at': null,
      'new_user_only': false,
      'new_user_started_at': null,
      'platform_specifications': 'APP',
      'started_at': '',
      'terms': '',
      'type': '',
      'updated_at': '',
      'voucher_payment_methods': [],
      'voucher_type': '',
    }
  };
  Map<String, dynamic> selectedPromoProduct = {
    'categoryVisible': '',
    'description': '',
    'img_url': '',
    'isActive': false,
    'isSelected': false,
    'price': '',
    'title': '',
    'value': ''
  };
  bool isFullWallet = false;
  bool useKickPoint = false;

  bool submittingPayment = false;

  var txt = TextEditingController();

  @override
  void initState() {
    super.initState();

    Api().getWithAuth('users/shipping').then((content) {
      final defaultShipping = content['data']
              .firstWhere((address) => address['is_default'] == true) ??
          {};

      setState(() {
        selectedAddress = defaultShipping;
      });
    });

    setState(() {
      currentProduct = Availables.fromJson(widget.product);
      price = currentProduct!.asking_price
          .substring(0, currentProduct!.asking_price.length - 3);
      txt.text = currentProduct!.asking_price
          .substring(0, currentProduct!.asking_price.length - 3);
    });
  }

  int calculatePriceDecuctedByVoucher() {
    int voucherAmount = selectedVoucher['voucher']['amount'] != ''
        ? int.parse(selectedVoucher['voucher']['amount']
            .substring(0, selectedVoucher['voucher']['amount'].length - 3))
        : 0;
    int totalVoucherUsage = selectedVoucher['voucher']['type'] == 'percentage'
        ? (int.parse(price) * voucherAmount / 100).round()
        : voucherAmount;
    int totalPrice = int.parse(price) - totalVoucherUsage;

    return totalPrice;
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
      int promoPrice = selectedPromoProduct['price'] != ''
          ? int.parse(selectedPromoProduct['price'])
          : 0;
      int shippingAndPromoProduct = shippingFee + promoPrice;

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
        'ka_courier_option': selectedPromoProduct['value'].isNotEmpty
            ? selectedPromoProduct['value']
            : 'FLAT_RATE',
        'ka_courier_price': shippingAndPromoProduct,
        'offer_amount': calculatePriceDecuctedByVoucher(),
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
        'amount': calculatePriceDecuctedByVoucher(),
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
        context.pushNamed('payment', params: {
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
    Map<String, dynamic> userInfo = ref.watch(userDataProvider);

    ref.read(courierProvider.notifier).fetch(
        country: selectedAddress['country'],
        province: selectedAddress['province'],
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
        calculatePriceDecuctedByVoucher() -
        int.parse(currentProduct!.subsidy_price ??
            '0'.substring(
                0,
                currentProduct!.subsidy_price == null
                    ? 1
                    : currentProduct!.subsidy_price!.length - 3));

    final bool enabledButton = payment.isNotEmpty &&
        amountToBePaid > 0 &&
        selectedAddress != {} &&
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
              child: InkWell(
                onTap: () async {
                  final address =
                      await showModalBottomSheet<Map<String, dynamic>>(
                    context: context,
                    builder: (BuildContext context) {
                      return const AddressBottomSheet();
                    },
                  );
                  setState(() {
                    if (address != null) {
                      selectedAddress = address;
                    }
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedAddress == {}
                          ? 'Shipping Address'
                          : '${selectedAddress['alias']} - ${selectedAddress['full_name']}',
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
            isBuyNow
                ? Container(
                    margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: InkWell(
                      onTap: () async {
                        final voucher =
                            await showModalBottomSheet<Map<String, dynamic>>(
                          context: context,
                          builder: (BuildContext context) {
                            return const VoucherBottomSheet();
                          },
                        );
                        setState(() {
                          if (voucher != null) {
                            print(voucher['voucher']);
                            selectedVoucher = voucher;
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedVoucher['voucher_id'] == 0
                                ? 'Select Voucher'
                                : '${selectedVoucher['voucher']['name']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                    ),
                  )
                : Container(),
            isBuyNow
                ? Container(
                    margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: InkWell(
                      onTap: () async {
                        final promoProduct =
                            await showModalBottomSheet<Map<String, dynamic>>(
                          context: context,
                          builder: (BuildContext context) {
                            return const PromoProductBottomSheet();
                          },
                        );
                        setState(() {
                          if (promoProduct != null) {
                            selectedPromoProduct = promoProduct;
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedPromoProduct['value'].isEmpty
                                ? 'Select Promo Product'
                                : '${selectedPromoProduct['title']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                    ),
                  )
                : Container(),
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
