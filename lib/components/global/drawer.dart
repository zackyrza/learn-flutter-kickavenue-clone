import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickavenue_clone/helper/database.dart';
import 'package:kickavenue_clone/provider/is_logged_in.dart';
import 'package:kickavenue_clone/provider/user.dart';

class DrawerWidget extends ConsumerWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isLoggedIn = ref.watch(loginStatusProvider);
    Map<String, dynamic> userInfo = ref.watch(userDataProvider);

    ref.read(loginStatusProvider.notifier).checkLogin();
    ref.read(userDataProvider.notifier).checkUser();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          isLoggedIn
              ? DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: SizedBox(
                    child: Column(
                      children: [
                        Text(
                            '${userInfo['first_name']} ${userInfo['family_name']}')
                      ],
                    ),
                  ),
                )
              : const SizedBox(
                  width: double.infinity,
                  height: 100,
                ),
          isLoggedIn
              ? ListTile(
                  title: const Text(
                    'Logout',
                  ),
                  onTap: () async {
                    await LocalStorage.instance.remove('user');
                    await LocalStorage.instance.remove('isLoggedIn');
                    ref.read(loginStatusProvider.notifier).removeLogin();
                    ref.read(userDataProvider.notifier).removeUser();
                  },
                )
              : ListTile(
                  title: const Text(
                    'Login',
                  ),
                  onTap: () {
                    context.goNamed('login');
                  },
                ),
        ],
      ),
    );
  }
}
