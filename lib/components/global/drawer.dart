import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kickavenue_clone/helper/database.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool isLoggedIn = false;
  Map<String, dynamic> userInfo = {};

  @override
  initState() {
    super.initState();

    setState(() {
      checkLogin().then((value) => isLoggedIn = value);
    });
    setState(() {
      checkUser().then((value) => userInfo = value);
    });
  }

  Future<Map<String, dynamic>> checkUser() async {
    final String userStringData = await LocalStorage.instance.get('user');
    if (userStringData.isNotEmpty) return json.decode(userStringData);
    return {};
  }

  Future<bool> checkLogin() async {
    final String loginStatus = await LocalStorage.instance.get('isLoggedIn');
    if (loginStatus.isNotEmpty) return loginStatus == 'true';
    return false;
  }

  @override
  Widget build(BuildContext context) {
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
                  onTap: () {},
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
