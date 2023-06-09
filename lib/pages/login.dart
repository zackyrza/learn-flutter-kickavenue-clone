import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickavenue_clone/api/dio.dart';
import 'package:kickavenue_clone/helper/database.dart';
import 'package:kickavenue_clone/provider/is_logged_in.dart';
import 'package:kickavenue_clone/provider/user.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  String email = '';
  String password = '';

  Future<bool> loggedIn() async {
    if (email.isEmpty) {
      const snackBar = SnackBar(
        duration: Duration(seconds: 5),
        content: Text("Email cannot be empty"),
        backgroundColor: Colors.red,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }

    if (password.isEmpty) {
      const snackBar = SnackBar(
        duration: Duration(seconds: 5),
        content: Text("Password cannot be empty"),
        backgroundColor: Colors.red,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }

    try {
      final loginResponse = await Api().post('auth', {
        'email': email,
        'password': password,
      });
      final token = loginResponse['data']['token'];
      await LocalStorage.instance.save('token', token);

      final userResponse = await Api().getWithAuth('auth');
      final user = userResponse['data'];
      await LocalStorage.instance.save('user', json.encode(user));
      await LocalStorage.instance.save('isLoggedIn', 'true');

      AlertDialog alert = AlertDialog(
        title: const Text("Login Succeeded"),
        content: const SizedBox(
          width: 500,
          height: 50,
          child: Text("Browse our magnificent shoe collection"),
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => context.goNamed('home'),
          ),
        ],
      );

      if (context.mounted) {
        showDialog(context: context, builder: (context) => alert);
      }
      return true;
    } catch (e) {
      const snackBar = SnackBar(
        duration: Duration(seconds: 2),
        content: Text("Error while logging you in."),
        backgroundColor: Colors.red,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => context.goNamed('home'),
            icon: const Icon(Icons.arrow_back_ios)),
        title: const Text('Login'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 80,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) => setState(() {
                email = value;
              }),
              decoration: const InputDecoration(
                hintText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              onChanged: (value) => setState(() {
                password = value;
              }),
              onEditingComplete: loggedIn,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
              keyboardType: TextInputType.visiblePassword,
            ),
            ElevatedButton(
              onPressed: () async {
                loggedIn().then((val) {
                  ref.read(loginStatusProvider.notifier).checkLogin();
                  ref.read(userDataProvider.notifier).checkUser();
                });
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
