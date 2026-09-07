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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF142236) : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF00A3FF).withValues(alpha: 0.35)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: selected
                      ? const Color(0xFF00C8FF)
                      : Colors.white.withValues(alpha: 0.35),
                  size: 24,
                  weight: 300,
                ),
              ),
              if (selected)
                Positioned(
                  left: -14,
                  top: 14,
                  bottom: 14,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A3FF),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00A3FF).withValues(alpha: 0.8),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
