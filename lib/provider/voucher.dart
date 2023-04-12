import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickavenue_clone/api/dio.dart';

final voucherProvider = FutureProvider<List<dynamic>>((ref) async {
  final content = await Api().getWithAuth('user_vouchers');
  final voucherList = content['data']['data'] ?? [];
  print(voucherList);

  return voucherList;
});
