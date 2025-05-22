import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavyNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavyNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade300, Colors.pink.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: BottomNavyBar(
        backgroundColor: Colors.transparent,
        selectedIndex: currentIndex,
        showElevation: true,
        itemCornerRadius: 24,
        curve: Curves.easeIn,
        onItemSelected: onTap,
        items: [
          BottomNavyBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
            activeColor: Color(0xffedf3ff),
            inactiveColor: Colors.white70,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.note_alt_sharp),
            title: Text('Notes'),
            activeColor: Color(0xffedf3ff),
            inactiveColor: Colors.white70,
          ),
          BottomNavyBarItem(
            icon: FaIcon(FontAwesomeIcons.tasks),
            title: Text('Tasks'),
            activeColor: Color(0xffedf3ff),
            inactiveColor: Colors.white70,
          ),
          BottomNavyBarItem(
            icon: Icon(FontAwesomeIcons.bookBookmark),
            title: Text('Lessons'),
            activeColor: Color(0xffedf3ff),
            inactiveColor: Colors.white70,
          ),
          BottomNavyBarItem(
            icon: Icon(FontAwesomeIcons.robot),
            title: Text('AI'),
            activeColor: Color(0xffedf3ff),
            inactiveColor: Colors.white70,
          ),
        ],
      ),
    );
  }
}