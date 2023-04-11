import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickavenue_clone/api/dio.dart';

final etaProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final content = await Api().request('settings?name=eta_text');
  final etaText = content['data']['data'][0]['value'] ?? {};

  return etaText;
});
