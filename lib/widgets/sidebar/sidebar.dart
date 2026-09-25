import 'package:flutter/material.dart';

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
      SidebarData(Icons.home_outlined, 'Home'),
      SidebarData(Icons.navigation_outlined, 'Navigation'),
      SidebarData(Icons.music_note_outlined, 'Media'),
      SidebarData(Icons.phone_outlined, 'Phone'),
      SidebarData(Icons.directions_car_outlined, 'Vehicle', enabled: false),
    ];

    const bottomItems = [
      SidebarData(Icons.settings_outlined, 'Settings', enabled: false),
    ];

    return Container(
      width: 90,
      decoration: const BoxDecoration(
        color: Color(0xFF111118),
        border: Border(right: BorderSide(color: Color(0x22FFFFFF), width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          for (var index = 0; index < topItems.length; index++)
            SidebarItem(
              key: ValueKey('sidebar-${topItems[index].label}'),
              icon: topItems[index].icon,
              label: topItems[index].label,
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
              enabled: bottomItems[index].enabled,
              disabledReason: bottomItems[index].enabled
                  ? null
                  : 'Module unavailable',
              selected: _currentIndex == topItems.length + index,
              onTap: bottomItems[index].enabled
                  ? () => _onTap(topItems.length + index)
                  : null,
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
