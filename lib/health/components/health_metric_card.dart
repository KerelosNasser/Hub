import 'package:flutter/material.dart';

class HealthMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor; // Changed from 'color' to 'iconColor' for clarity
  final VoidCallback onTap;

  const HealthMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBackgroundColor = Colors.pink.shade900;
    final Color primaryTextColor = const Color(0xffedf3ff);
    final Color secondaryTextColor = primaryTextColor.withOpacity(0.7);
    final screenWidth = MediaQuery.of(context).size.width;
    final double iconSize = screenWidth < 600 ? 28 : 32;
    final double titleFontSize = screenWidth < 600 ? 14 : 16;
    final double valueFontSize = screenWidth < 600 ? 18 : 20;
    final double unitFontSize = screenWidth < 600 ? 12 : 14;

    return Card(
      elevation: 4,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03), // Responsive padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: iconColor),
              SizedBox(height: screenWidth * 0.015),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor),
              ),
              SizedBox(height: screenWidth * 0.01),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: valueFontSize,
                    color: iconColor,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                unit,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: unitFontSize, color: secondaryTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
