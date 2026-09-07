import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0B0B10),
        border: Border(
          bottom: BorderSide(
            color: Color(0x12FFFFFF),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 28,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                'V',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              'V E L T R O N',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 18,
                fontWeight: FontWeight.w300,
                letterSpacing: 8,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Positioned(
            right: 28,
            top: 0,
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.bluetooth,
                  color: Colors.white70,
                  size: 18,
                ),
                SizedBox(width: 18),
                Icon(
                  Icons.signal_cellular_alt,
                  color: Colors.white70,
                  size: 18,
                ),
                SizedBox(width: 18),
                Icon(
                  Icons.wifi,
                  color: Colors.white70,
                  size: 18,
                ),
                SizedBox(width: 24),
                Text(
                  '10:42',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}