import 'package:flutter/material.dart';

class SidebarData {
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const SidebarData(
    this.icon, {
    this.selected = false,
    this.onTap,
  });
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF1C1C26) : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: selected
                  ? Colors.white.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.35),
              size: 24,
              weight: 300,
            ),
          ),
        ),
      ),
    );
  }
}
