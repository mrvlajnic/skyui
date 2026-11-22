import 'package:flutter/material.dart';

/// Minimal attribution chip for the basemap layers.
///
/// The OpenStreetMap and provider credits are required when their tiles or
/// styles are displayed, so they stay visible but deliberately tiny. The
/// `flutter_map` package branding that [SimpleAttributionWidget] prepends is
/// not required and is omitted.
class MapAttribution extends StatelessWidget {
  final Alignment alignment;
  final String text;

  const MapAttribution({
    super.key,
    this.alignment = Alignment.bottomLeft,
    this.text = '© OpenStreetMap contributors',
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0x33FFFFFF),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 7,
                height: 1.1,
                color: Color(0x8A000000),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
