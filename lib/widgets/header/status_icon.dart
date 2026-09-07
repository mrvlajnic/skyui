import 'package:flutter/material.dart';

class StatusIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  const StatusIcon({
    super.key,
    required this.icon,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1C1C26) : const Color(0xFF111118),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? const Color(0x33FFFFFF) : const Color(0x1AFFFFFF),
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: active ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}