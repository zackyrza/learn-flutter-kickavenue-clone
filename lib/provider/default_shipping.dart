import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickavenue_clone/api/dio.dart';

final defaultShippingProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final content = await Api().getWithAuth('users/shipping');
  final defaultShipping =
      content['data'].firstWhere((address) => address['is_default'] == true) ??
          {};

  return defaultShipping;
});
