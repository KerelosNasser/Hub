import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:async';

class FarahhubController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> bounceAnimation;
  late AnimationController textAnimationController;
  late Animation<Offset> textSlideAnimation;
  late Animation<double> textFadeAnimation;
  final box = GetStorage();

  var currentRotation = 0.0.obs;
  var rotationVelocity = 0.0.obs;
  late Timer rotationTimer;
  var startOffset = const Offset(0, 0).obs;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    currentRotation.value = box.read('currentRotation') ?? 0.0;
    rotationVelocity.value = box.read('rotationVelocity') ?? 0.0;

    bounceAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.bounceInOut,
    );

    textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: textAnimationController,
      curve: Curves.easeInOut,
    ));

    textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: textAnimationController,
      curve: Curves.easeIn,
    ));

    rotationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      currentRotation.value += rotationVelocity.value;
      rotationVelocity.value *= 0.7;
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    textAnimationController.dispose();
    rotationTimer.cancel();
    super.onClose();
  }

  void onPanStart(DragStartDetails details) {
    startOffset.value = details.globalPosition;
    rotationVelocity.value = 0.2;
  }

  void onPanUpdate(DragUpdateDetails details) {
    final currentOffset = details.globalPosition;
    final delta = currentOffset - startOffset.value;
    final angleDelta = delta.distance / 200.0;

    rotationVelocity.value += angleDelta;
    startOffset.value = currentOffset;
  }

  void showAnimatedMessage(BuildContext context) {
    textAnimationController.forward(from: 0.0);

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).size.height * 0.1,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: SlideTransition(
          position: textSlideAnimation,
          child: FadeTransition(
            opacity: textFadeAnimation,
            child: Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: MediaQuery.of(context).size.width * 0.04,
                    spreadRadius: MediaQuery.of(context).size.width * 0.02,
                  ),
                ],
              ),
              child: Text(
                "❤️ Happy BirthDay Farfora 🥳❤️",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                  color: const Color(0xFFf7919e),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void replayOnboarding() {
    final box = GetStorage();
    box.write('hasCompletedOnboarding', false);
    Get.offAllNamed('/onboarding');
  }
}
