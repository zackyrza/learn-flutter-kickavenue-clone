// ignore_for_file: constant_identifier_names

import 'dart:math';

String imageExtractor(String? url) {
  return url ??
      'https://devweb.kickavenue.com/static/media/kick_avenue_empty_image.cf172573.png';
}

String sneakersCondition(String condition) {
  switch (condition) {
    case "BARU":
      return "Brand New";
    case "BEKAS":
      return "Used";
    case "PREORDER":
      return "Pre-Order";
    case "PREVERIFIED":
      return "Express Shipping";
    case "PRISTINE":
      return "Pristine";
    case "GOOD":
      return "Good";
    case "WELL_USED":
      return "Well Used";
    case "LIKE_NEW":
      return "Like New";
    case "VINTAGE":
      return "Vintage";
    default:
      return "Brand New";
  }
}

String accessoriesCondition(bool data) {
  switch (data) {
    case false:
      return "Complete Accessories";
    case true:
      return "Missing Accessories";

    default:
      return "Complete Accessories";
  }
}

String boxCondition(String condition) {
  switch (condition) {
    case "SEMPURNA":
      return "Perfect Box";
    case "CACAT":
      return "Damaged Box";
    case "NO_BOX":
      return "Missing Box";

    default:
      return "Perfect Box";
  }
}

List<T> uniqBy<T, K>(List<T> list, K Function(T) keyFn) {
  return list.toSet().toList();
}

String estimatedTimeArrivals(bool preVerified, bool isEventActive,
    String condition, Map<String, dynamic> text) {
  final String etaStandard = text['eta_standard'] ?? '';
  final String etaPreverified = text['eta_preverified'] ?? '';
  final String etaPreverifiedEvent = text['eta_preverified_event'] ?? '';
  final String etaPreorder = text['eta_preorder'] ?? '';

  return preVerified && isEventActive
      ? etaPreverifiedEvent
      : preVerified && !isEventActive
          ? etaPreverified
          : condition == 'PO'
              ? etaPreorder
              : etaStandard;
}

const String BANKTRANSFER = 'bank_transfer';
const String VIRTUALACCOUNT = 'virtual_account';
const String BCA_VA = 'bca_va';
const String BNI_VA = 'bni_va';
const String BRI_VA = 'bri_va';
const String PERMATA_VA = 'permata_va';
const String MANDIRI_VA = 'mandiri_va';
const String CREDITCARD = 'credit_card';
const String BCA_CREDIT_CARD = 'bca_credit_card';
const String MANDIRI_CREDIT_CARD = 'mandiri_credit_card';
const String BCA_INSTALLMENTS = 'bca_installments';
const String KREDIVO = 'kredivo';
const String ATOME = 'atome';
const String AKULAKU = 'akulaku';
const String GOPAY = 'gopay';
const String FULLWALLET = 'full_wallet';
const String KICK_POINT = 'kick_point';
const String INSTALLMENTS = 'installments';
const String BCA_KLIK_PAY = 'bca_klikpay';
const String BCA_ONEKLIK = 'bca_oneklik';

final List<Map<String, dynamic>> defaultPaymentMethod = [
  {
    'id': Random().nextDouble(),
    'label': 'Full Wallet',
    'payment_method': FULLWALLET,
    'payment_group': 3,
    'active': true,
  },
  {
    'id': Random().nextDouble(),
    'label': 'BCA Credit Card / Debit Card',
    'payment_method': BCA_CREDIT_CARD,
    'payment_group': 1,
    'type': "credit_card",
    'active': true,
  },
  {
    'id': Random().nextDouble(),
    'label': 'BCA Installments',
    'payment_method': BCA_INSTALLMENTS,
    'payment_group': 1,
    'type': 'credit_card',
    'active': true,
  },
  {
    'id': Random().nextDouble(),
    'label': 'BCA Card',
    'payment_method': CREDITCARD,
    'payment_group': 1,
    'type': 'credit_card',
    'active': true,
  },
  {
    'id': Random().nextDouble(),
    'label': 'MANDIRI Installments',
    'payment_method': MANDIRI_CREDIT_CARD,
    'payment_group': 1,
    'type': "credit_card",
    'active': true,
  },
  {
    'id': Random().nextDouble(),
    'label': 'Credit Card / Debit Card / Installments',
    'payment_method': CREDITCARD,
    'payment_group': 1,
    'type': 'credit_card',
    'active': true,
  },
  {
    'id': Random().nextDouble(),
    'label': 'Bank Transfer',
    'payment_method': BANKTRANSFER,
    'payment_group': 1,
    'type': 'bank_transfer',
    'active': true,
  },
  {
    'id': Random().nextDouble(),
    'label': 'BCA',
    'payment_method': BCA_VA,
    'payment_group': 1,
    'type': 'virtual_account',
    'active': true,
  },
  {
    'id': Random().nextDouble(),
    'label': 'MANDIRI',
    'payment_method': MANDIRI_VA,
    'payment_group': 1,
    'type': 'virtual_account',
    'active': true,
  },
  {
    'id': Random().nextDouble(),
    'label': 'PERMATA',
    'payment_method': PERMATA_VA,
    'payment_group': 1,
    'type': 'virtual_account',
    'active': true,
  },
  {
    'id': Random().nextDouble(),
    'label': 'BNI',
    'payment_method': BNI_VA,
    'payment_group': 1,
    'type': 'virtual_account',
    'active': true,
  },
  {
    'id': Random().nextDouble(),
    'label': 'BRI',
    'payment_method': BRI_VA,
    'payment_group': 1,
    'type': 'virtual_account',
    'active': true,
  },
  {
    'id': Random().nextDouble(),
    'label': 'GOPAY',
    'payment_method': GOPAY,
    'payment_group': 1,
    'type': 'virtual_account',
    'active': true,
  },
  {
    'id': Random().nextDouble(),
    'label': 'Other Virtual Account',
    'payment_method': VIRTUALACCOUNT,
    'payment_group': 1,
    'type': 'virtual_account',
    'active': true,
  },
  {
    'id': Random().nextDouble(),
    'label': 'Atome Installments',
    'payment_method': ATOME,
    'payment_group': 2,
    'active': true,
  },
  {
    'id': Random().nextDouble(),
    'label': 'Akulaku Installments',
    'payment_method': AKULAKU,
    'payment_group': 2,
    'active': true,
  },
  {
    'id': Random().nextDouble(),
    'label': 'KREDIVO Installments',
    'payment_method': KREDIVO,
    'payment_group': 2,
    'active': true,
  },
];
