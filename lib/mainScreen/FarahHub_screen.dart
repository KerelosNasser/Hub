import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';
import 'app-launching-service.dart';
import 'controller.dart';

class FarahhubScreen extends StatelessWidget {
  FarahhubScreen({super.key});

  final FarahhubController controller = Get.put(FarahhubController());
  final AppLauncherService appLauncherService = Get.put(AppLauncherService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double radius = min(constraints.maxWidth, constraints.maxHeight) * 0.4;
          final double centerCircleSize = constraints.maxWidth * 0.35;
          final double iconCircleSize = constraints.maxWidth * 0.22;
          final double iconSize = constraints.maxWidth * 0.11;

          return GestureDetector(
            onPanStart: controller.onPanStart,
            onPanUpdate: controller.onPanUpdate,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.pinkAccent.shade700,
                          Colors.pink.shade600.withOpacity(0.6),
                          Colors.pink.shade800,
                        ],
                        stops: const [0.1, 0.6, 0.9],
                        center: Alignment.center,
                        radius: 1.2,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.showAnimatedMessage(context),
                    child: AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      width: centerCircleSize,
                      height: centerCircleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xffedf3ff),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/Screenshot (4).jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  ...List.generate(6, (index) {
                    return Obx(() {
                      final angle = controller.currentRotation.value + (2 * pi / 6) * index;

                      final iconData = [
                        FontAwesomeIcons.snapchat,
                        FontAwesomeIcons.facebook,
                        FontAwesomeIcons.instagram,
                        FontAwesomeIcons.whatsapp,
                        FontAwesomeIcons.comment,
                        FontAwesomeIcons.tiktok,
                      ];
                      final packageNames = [
                        'com.snapchat.android',
                        'com.facebook.katana',
                        'com.instagram.android',
                        'com.whatsapp',
                        'com.whatsapp',
                        'com.zhiliaoapp.musically'
                      ];
                      final urlSchemes = [
                        'snapchat://',
                        'fb://',
                        'instagram://',
                        'whatsapp://',
                        'https://wa.me/+201211730727',
                        'tiktok://'
                      ];

                      return Transform.translate(
                        offset: Offset(
                          radius * cos(angle),
                          radius * sin(angle),
                        ),
                        child: AnimatedBuilder(
                          animation: controller.bounceAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1 + 0.1 * controller.bounceAnimation.value,
                              child: GestureDetector(
                                onTap: () {
                                  appLauncherService.onButtonPressed(
                                    packageNames[index],
                                    urlSchemes[index],
                                    specificChat: index == 4 ? urlSchemes[index] : null,
                                  );
                                },
                                child: Container(
                                  width: iconCircleSize,
                                  height: iconCircleSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.pinkAccent.shade700,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.pink.withOpacity(0.4),
                                        blurRadius: 12,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: index == 4
                                        ? Text(
                                      "wanna talk?",
                                      style: TextStyle(
                                        color: const Color(0xffedf3ff),
                                        fontWeight: FontWeight.bold,
                                        fontSize: constraints.maxWidth * 0.04,
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                        : Icon(
                                      iconData[index],
                                      color: const Color(0xffedf3ff),
                                      size: iconSize,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    });
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
