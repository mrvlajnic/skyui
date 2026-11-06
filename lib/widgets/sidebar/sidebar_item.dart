import 'package:flutter/material.dart';

import '../../core/icons/sky_icon.dart';

class SidebarData {
  final SkyIconData icon;
  final String label;
  final bool enabled;

  const SidebarData(this.icon, this.label, {this.enabled = true});
}

class SidebarItem extends StatefulWidget {
  final SkyIconData icon;
  final String label;
  final bool selected;
  final bool enabled;
  final String? disabledReason;
  final VoidCallback? onTap;
  final double height;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
    this.enabled = true,
    this.disabledReason,
    this.onTap,
    this.height = 80,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final reason = widget.disabledReason ?? 'Unavailable in this prototype';
    final enabled = widget.enabled;
    final selected = widget.selected;

    final Color iconColor;
    if (!enabled) {
      iconColor = Colors.white.withValues(alpha: 0.30);
    } else if (selected) {
      iconColor = const Color(0xFFF5F6F8);
    } else if (_hovered || _focused) {
      iconColor = Colors.white.withValues(alpha: 0.78);
    } else {
      iconColor = Colors.white.withValues(alpha: 0.58);
    }

    return Semantics(
      container: true,
      button: true,
      selected: selected,
      enabled: enabled,
      inMutuallyExclusiveGroup: true,
      label: widget.label,
      hint: enabled ? null : reason,
      onTap: enabled ? widget.onTap : null,
      excludeSemantics: true,
      child: Tooltip(
        message: enabled ? widget.label : '${widget.label} — $reason',
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: SizedBox(
            width: double.infinity,
            height: widget.height,
            child: Stack(
              children: [
                // Active module marker: a subtle neutral rounded tile behind
                // the icon. No bar, border, glow, or accent color.
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: selected ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),

                // Neutral focus ring; never uses the accent color.
                if (_focused)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.55),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: enabled ? widget.onTap : null,
                      onHover: enabled
                          ? (value) {
                              if (value != _hovered) {
                                setState(() => _hovered = value);
                              }
                            }
                          : null,
                      onFocusChange: enabled
                          ? (value) {
                              if (value != _focused) {
                                setState(() => _focused = value);
                              }
                            }
                          : null,
                      canRequestFocus: enabled,
                      mouseCursor: enabled
                          ? SystemMouseCursors.click
                          : SystemMouseCursors.basic,
                      splashFactory: NoSplash.splashFactory,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      highlightColor: Colors.white.withValues(alpha: 0.04),
                      child: Center(
                        child: SkyIcon(widget.icon, size: 26, color: iconColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
