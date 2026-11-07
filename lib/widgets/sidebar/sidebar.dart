import 'package:flutter/material.dart';

import '../../core/icons/sky_icons.dart';
import 'sidebar_item.dart';

class Sidebar extends StatefulWidget {
  final int? selectedIndex;
  final ValueChanged<int>? onItemSelected;
  final bool interactionLocked;

  const Sidebar({
    super.key,
    this.selectedIndex,
    this.onItemSelected,
    this.interactionLocked = false,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _internalIndex = 0;

  int get _currentIndex => widget.selectedIndex ?? _internalIndex;

  void _onTap(int index) {
    if (widget.onItemSelected != null) {
      widget.onItemSelected!(index);
    } else {
      setState(() {
        _internalIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const topItems = [
      SidebarData(SkyIcons.house, 'Home'),
      SidebarData(SkyIcons.navigation, 'Navigation'),
      SidebarData(SkyIcons.music, 'Media'),
      SidebarData(SkyIcons.phone, 'Phone'),
      SidebarData(SkyIcons.vehicle, 'Vehicle'),
    ];

    const bottomItems = [
      SidebarData(SkyIcons.settings, 'Settings', enabled: false),
    ];

    return Container(
      width: 108,
      decoration: const BoxDecoration(
        color: Color(0xFF111118),
        border: Border(right: BorderSide(color: Color(0x22FFFFFF), width: 1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const topGap = 24.0;
          const bottomGap = 20.0;
          final itemCount = topItems.length + bottomItems.length;

          // Keep all destinations visible on shorter logical viewports
          // (e.g. Windows display scaling) while preserving the airy 80 dp
          // rows at the 1680x720 baseline.
          final itemHeight =
              ((constraints.maxHeight - topGap - bottomGap) / itemCount)
                  .clamp(64.0, 80.0)
                  .toDouble();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: topGap),
              for (var index = 0; index < topItems.length; index++)
                SidebarItem(
                  key: ValueKey('sidebar-${topItems[index].label}'),
                  icon: topItems[index].icon,
                  label: topItems[index].label,
                  height: itemHeight,
                  enabled:
                      topItems[index].enabled &&
                      (!widget.interactionLocked || _currentIndex == index),
                  disabledReason: !topItems[index].enabled
                      ? 'Module unavailable'
                      : widget.interactionLocked && _currentIndex != index
                      ? 'Unavailable while a call is active'
                      : null,
                  selected: _currentIndex == index,
                  onTap:
                      topItems[index].enabled &&
                          (!widget.interactionLocked || _currentIndex == index)
                      ? () => _onTap(index)
                      : null,
                ),
              const Spacer(),
              for (var index = 0; index < bottomItems.length; index++)
                SidebarItem(
                  key: ValueKey('sidebar-${bottomItems[index].label}'),
                  icon: bottomItems[index].icon,
                  label: bottomItems[index].label,
                  height: itemHeight,
                  enabled: bottomItems[index].enabled,
                  disabledReason: bottomItems[index].enabled
                      ? null
                      : 'Module unavailable',
                  selected: _currentIndex == topItems.length + index,
                  onTap: bottomItems[index].enabled
                      ? () => _onTap(topItems.length + index)
                      : null,
                ),
              const SizedBox(height: bottomGap),
            ],
          );
        },
      ),
    );
  }
}
