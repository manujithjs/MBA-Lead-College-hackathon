import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_onboarding_screen.dart';
import 'screens/client/client_home_screen.dart';
import 'screens/provider/provider_home_screen.dart';
import 'services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => FirebaseService(),
      child: const CraftBridgeApp(),
    ),
  );
}

class CraftBridgeApp extends StatelessWidget {
  const CraftBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CraftBridge (Softi)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _RootRouter(),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FirebaseService>();

    if (!fs.authReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (fs.user == null) {
      return const AuthOnboardingScreen();
    }

    if (fs.activePortal == 'provider') {
      return const ProviderHomeScreen();
    }

    return const ClientHomeScreen();
  }
}
