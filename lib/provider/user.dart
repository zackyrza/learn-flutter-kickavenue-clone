import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../helper/database.dart';

class User extends StateNotifier<Map<String, dynamic>> {
  User(this.ref) : super({});

  final Ref ref;

  void checkUser() async {
    final String loginStatus = await LocalStorage.instance.get('user');
    if (loginStatus.isNotEmpty) {
      state = json.decode(loginStatus);
      return;
    }
    state = {};
  }

  void removeUser() {
    state = {};
  }
}

final userDataProvider =
    StateNotifierProvider<User, Map<String, dynamic>>((ref) {
  return User(ref);
});
