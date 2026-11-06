import 'package:flutter/material.dart';

import 'core/theme/theme.dart';
import 'widgets/common/app_preloader.dart';
import 'widgets/header/header.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const SkyUIApp(showPreloader: true));
}

class SkyUIApp extends StatelessWidget {
  /// Enables the startup overlay. Off by default so tests can mount the app
  /// without boot timing; the production entry point turns it on.
  final bool showPreloader;

  const SkyUIApp({super.key, this.showPreloader = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Veltron OS - SkyUI',
      theme: AppTheme.theme(),
      builder: (context, child) {
        return AppPreloader(
          enabled: showPreloader,
          child: SafeArea(
            bottom: false,
            child: Material(
              // The header renders outside the Home Screen Scaffold, so the
              // fallback DefaultTextStyle (red monospace with a yellow double
              // underline) without it. A transparent Material restores sane
              // text inheritance without changing the header's look.
              type: MaterialType.transparency,
              child: Column(
                children: [
                  const Header(),
                  Expanded(child: child ?? const SizedBox.shrink()),
                ],
              ),
            ),
          ),
        );
      },
      home: const HomeScreen(),
    );
  }
}
