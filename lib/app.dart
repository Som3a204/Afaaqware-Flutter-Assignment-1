import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/cart/presentation/cart_controller.dart';
import 'features/products/data/product_repository.dart';
import 'features/products/presentation/home_screen.dart';
import 'features/products/presentation/product_controller.dart';

/// Composition root: all long-lived state is created once, above the
/// [MaterialApp], so it survives navigation between screens.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(MockAuthRepository()),
        ),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(
          create: (_) => ProductController(MockProductRepository())..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Mini Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

/// Chooses the root screen from the auth state, so login/logout never needs
/// manual navigation and the back button can't return to a stale screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated =
    context.select<AuthController, bool>((a) => a.isAuthenticated);
    return isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}
