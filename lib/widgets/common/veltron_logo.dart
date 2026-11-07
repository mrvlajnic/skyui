import 'package:flutter/material.dart';

/// Veltron brand mark: the user-supplied metallic V logo
/// (@assets/images/logo.png, also packaged as the Windows app icon).
class VeltronLogo extends StatelessWidget {
  /// Rendered box; the mark fills the box with [mainAxisAlignment] centered.
  final double size;

  const VeltronLogo({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
