import 'package:flutter/material.dart';

class SidebarData {
  final IconData icon;
  final String label;
  final bool enabled;

  const SidebarData(this.icon, this.label, {this.enabled = true});
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool enabled;
  final String? disabledReason;
  final VoidCallback? onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
    this.enabled = true,
    this.disabledReason,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final reason = disabledReason ?? 'Unavailable in this prototype';
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      hint: enabled ? null : reason,
      onTap: enabled ? onTap : null,
      excludeSemantics: true,
      child: Tooltip(
        message: enabled ? label : '$label — $reason',
        child: Opacity(
          opacity: enabled ? 1 : 0.35,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? onTap : null,
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
                        color: selected
                            ? const Color(0xFF142236)
                            : Colors.transparent,
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
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF00A3FF,
                                ).withValues(alpha: 0.8),
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
          ),
        ),
      ),
    );
  }
}
