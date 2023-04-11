import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickavenue_clone/api/dio.dart';

final shippingProvider = FutureProvider<List<dynamic>>((ref) async {
  final content = await Api().getWithAuth('users/shipping');
  final shippingList = content['data'] ?? [];

  return shippingList;
});
