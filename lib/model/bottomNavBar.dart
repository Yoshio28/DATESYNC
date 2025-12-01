import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BottomNavbar extends StatelessWidget {
  final List<Widget> items;
  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final double? height;

  const BottomNavbar({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor = const Color(0xFF64B5F6),
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.height = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: backgroundColor!,
      animationCurve: animationCurve!,
      animationDuration: animationDuration!,
      height: height!,
      items: items,
      index: currentIndex,
      onTap: onTap,
    );
  }
}
