import 'package:flutter/material.dart';

import 'core/theme/theme.dart';
import 'widgets/common/app_preloader.dart';
import 'widgets/display/burn_in_guard.dart';
import 'widgets/header/header.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const SkyUIApp(showPreloader: true, burnInMitigation: true));
}

class SkyUIApp extends StatelessWidget {
  /// Enables the startup overlay. Off by default so tests can mount the app
  /// without boot timing; the production entry point turns it on.
  final bool showPreloader;

  /// Enables the OLED pixel-shift and idle-dim guards. Off by default for the
  /// same reason as [showPreloader]: tests should not run a continuous
  /// animation. See `BurnInGuard` and DEC-009.
  final bool burnInMitigation;

  const SkyUIApp({
    super.key,
    this.showPreloader = false,
    this.burnInMitigation = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Veltron OS - SkyUI',
      theme: AppTheme.theme(),
      builder: (context, child) {
        return BurnInGuard(
          enabled: burnInMitigation,
          child: AppPreloader(
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
                    Expanded(
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      home: const HomeScreen(),
    );
  }
}
