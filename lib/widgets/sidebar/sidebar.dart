import 'package:flutter/material.dart';

import 'sidebar_item.dart';

class Sidebar extends StatefulWidget {
  final int? selectedIndex;
  final ValueChanged<int>? onItemSelected;

  const Sidebar({
    super.key,
    this.selectedIndex,
    this.onItemSelected,
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
      SidebarData(Icons.home_outlined),
      SidebarData(Icons.navigation_outlined),
      SidebarData(Icons.music_note_outlined),
      SidebarData(Icons.phone_outlined),
      SidebarData(Icons.directions_car_outlined),
    ];

    const bottomItems = [
      SidebarData(Icons.settings_outlined),
    ];

    return Container(
      width: 90,
      decoration: const BoxDecoration(
        color: Color(0xFF111118),
        border: Border(
          right: BorderSide(
            color: Color(0x22FFFFFF),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          for (var index = 0; index < topItems.length; index++)
            SidebarItem(
              icon: topItems[index].icon,
              selected: _currentIndex == index,
              onTap: () => _onTap(index),
            ),
          const Spacer(),
          for (var index = 0; index < bottomItems.length; index++)
            SidebarItem(
              icon: bottomItems[index].icon,
              selected: _currentIndex == topItems.length + index,
              onTap: () => _onTap(topItems.length + index),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
