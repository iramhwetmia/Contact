import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'Login.dart';
import 'Register.dart';
import 'Contact.dart';
import 'AuthService.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.init();

  final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = AuthService.instance.isLoggedIn;
      final goingToLogin = state.name == 'login';
      final goingToRegister = state.name == 'register';
      // debug
      debugPrint('Router.redirect: name=${state.name} loggedIn=$loggedIn');

      // If the user IS logged in and tries to go to login or register, send to contacts
      if (loggedIn && (goingToLogin || goingToRegister)) {
        debugPrint('Router.redirect: logged -> redirect to /contacts');
        return '/contacts';
      }

      // Allow unauthenticated navigation (login/register/other) — no forced redirect here
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/contacts',
        name: 'contacts',
        builder: (context, state) => const ContactsPage(),
      ),
    ],
  );

  runApp(MyApp(router: router));
}

class MyApp extends StatelessWidget {
  final GoRouter router;

  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gestion de contacts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple),
      routerConfig: router,
    );
  }
}
