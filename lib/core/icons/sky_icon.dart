import 'package:flutter/material.dart';

class SkyIconData {
  final IconData iconData;

  const SkyIconData(this.iconData);
}

class SkyIcon extends StatelessWidget {
  final SkyIconData icon;
  final double size;
  final Color? color;
  final String? semanticLabel;

  const SkyIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon.iconData,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}
