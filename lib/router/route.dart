import 'package:go_router/go_router.dart';
import 'package:kickavenue_clone/pages/login.dart';
import 'package:kickavenue_clone/pages/product.dart';

import '../pages/error.dart';
import '../pages/home.dart';
import '../pages/setting.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      name: 'home',
      path: "/",
      builder: (context, state) => const HomePage(),
      redirect: (context, state) {
        const userIsNotLoggedIn = false;
        if (userIsNotLoggedIn) {
          return "/login";
        }
        return "/";
      },
    ),
    GoRoute(
      name: 'settings',
      path: "/settings/:name",
      builder: (context, state) {
        state.queryParams.forEach(
          (key, value) {
            print("$key:$value");
          },
        );
        return SettingsPage(
          name: state.params["name"]!,
        );
      },
    ),
    GoRoute(
      name: 'product',
      path: "/product/:slug/:name",
      builder: (context, state) {
        return ProductPage(
          name: state.params["name"]!,
          slug: state.params["slug"]!,
        );
      },
    ),
    GoRoute(
      name: 'login',
      path: "/login",
      builder: (context, state) {
        return const LoginPage();
      },
    ),
  ],
  errorBuilder: (context, state) => const ErrorScreen(),
);
