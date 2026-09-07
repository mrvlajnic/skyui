import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final String label;
  final Widget? child;

  const AppCard({
    super.key,
    required this.label,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111118),
        border: Border.all(
          color: const Color(0x22FFFFFF),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child ??
          Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
    );
  }
}
