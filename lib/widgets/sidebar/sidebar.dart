import 'package:flutter/material.dart';

import 'sidebar_item.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int selectedIndex = 0;

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
              selected: selectedIndex == index,
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          const Spacer(),
          for (var index = 0; index < bottomItems.length; index++)
            SidebarItem(
              icon: bottomItems[index].icon,
              selected: selectedIndex == topItems.length + index,
              onTap: () {
                setState(() {
                  selectedIndex = topItems.length + index;
                });
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
