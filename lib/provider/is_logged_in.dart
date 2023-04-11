import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../helper/database.dart';

class IsLoggedIn extends StateNotifier<bool> {
  IsLoggedIn(this.ref) : super(false);

  final Ref ref;

  void checkLogin() async {
    final String loginStatus = await LocalStorage.instance.get('isLoggedIn');
    if (loginStatus.isNotEmpty) {
      state = loginStatus == 'true';
      return;
    }
    state = false;
  }

  void removeLogin() {
    state = false;
  }
}

final loginStatusProvider = StateNotifierProvider<IsLoggedIn, bool>((ref) {
  return IsLoggedIn(ref);
});
