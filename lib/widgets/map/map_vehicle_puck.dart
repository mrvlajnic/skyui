import 'package:flutter/material.dart';

/// Simulated ego position marker for the map surfaces.
///
/// No positioning source is integrated; this is a fixture styled like a
/// standard navigation puck so both the real tiles and the painted fallback
/// read the same way.
class MapVehiclePuck extends StatelessWidget {
  const MapVehiclePuck({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Simulated vehicle position',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0A84FF),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A84FF).withValues(alpha: 0.35),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.navigation, color: Colors.white, size: 18),
      ),
    );
  }
}
