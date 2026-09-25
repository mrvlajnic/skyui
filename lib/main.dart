import 'package:flutter/material.dart';

import 'core/theme/theme.dart';
import 'widgets/header/header.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const SkyUIApp());
}

class SkyUIApp extends StatelessWidget {
  const SkyUIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Veltron OS - SkyUI',
      theme: AppTheme.theme(),
      builder: (context, child) {
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              const Header(),
              Expanded(child: child ?? const SizedBox.shrink()),
            ],
          ),
        );
      },
      home: const HomeScreen(),
    );
  }
}
