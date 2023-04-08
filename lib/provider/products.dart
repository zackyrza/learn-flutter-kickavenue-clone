import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickavenue_clone/api/dio.dart';

class ProductStateNotifier extends StateNotifier<List<dynamic>> {
  ProductStateNotifier() : super([]);

  int page = 1;
  String _keyword = '';

  set changeKeyword(String keyword) {
    _keyword = keyword;
  }

  get keyword {
    return _keyword;
  }

  void fetch(
      bool reset, VoidCallback beforeFetch, VoidCallback afterFetch) async {
    if (!reset) {
      beforeFetch();
    }

    final content = await Api.elasticSearch().request(
        '?page=${reset ? 1 : page}&availables=true&category=&per_page=10&sort_by=most_popular&keyword=$keyword');
    final List data = content['data']['data'];
    page++;

    if (!reset) {
      afterFetch();
    }

    if (reset == false) {
      state += data;
      return;
    }

    state = data;
  }
}

final productProvider =
    StateNotifierProvider<ProductStateNotifier, List<dynamic>>((ref) {
  return ProductStateNotifier();
});
