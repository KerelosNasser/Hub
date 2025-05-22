
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconSection extends StatelessWidget {
  const IconSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20), // Adjust the margin as needed
      child: Center(
        child: Icon(
          FontAwesomeIcons.noteSticky, // FontAwesome Icon
          size: 150,
          color: Color(0xffedf3ff),

        ),
      ),
    );
  }
}
