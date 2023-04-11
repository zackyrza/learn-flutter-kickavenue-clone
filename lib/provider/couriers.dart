import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickavenue_clone/api/dio.dart';

class CourierStateNotifier extends StateNotifier<int> {
  CourierStateNotifier() : super(0);

  void fetch({
    required String country,
    String courier = 'FLAT_RATE',
    required String province,
    required int productPrice,
    required int productVariantId,
    required int weight,
  }) async {
    final provinceResult =
        await Api().request('postalcode/province?country=$country');
    final List<dynamic> provinceList = provinceResult['data'].toList();
    if (provinceList.isNotEmpty) {
      final provinceId = provinceList.firstWhere((element) {
        return element['name'] == province;
      })['id'];
      final content = await Api().post('couriers', {
        'country': country,
        'courier': courier,
        'destination': provinceId,
        'product_price': productPrice,
        'product_variant_id': productVariantId,
        'weight': weight,
      });
      state = content['data'];
    }
  }
}

final courierProvider = StateNotifierProvider<CourierStateNotifier, int>((ref) {
  return CourierStateNotifier();
});
