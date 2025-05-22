import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _playAudio();
  }

  Future<void> _playAudio() async {
    final audioPlayer = AudioPlayer();
    await audioPlayer.play(AssetSource('birthday.mp3'));
  }

  Future<void> _completeOnboarding() async {
    final box = GetStorage();
    // Example usage if a DateTime is being stored:
    final currentDateTime = DateTime.now().toIso8601String();
    box.write('hasCompletedOnboarding', true);
    box.write('completionTime', currentDateTime); // Ensure proper encoding
    Get.offAllNamed(AppRoutes.farahHub); // Navigate to the main app
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: List.generate(14, (index) {
          Color color;
          if (index < 6) {
            color = Color.lerp(Colors.black, const Color(0xFF660000), index / 5)!;
          } else if (index < 10) {
            color = Color.lerp(const Color(0xFF660000), const Color(0xFFFF3366), (index - 6) / 4)!;
          } else {
            color = Color.lerp(const Color(0xFFFF3366), Colors.pink, (index - 10) / 3)!;
          }
          return OnBoardingPageContent(
            color: color,
            description: [
              "hello farah 🥰💕",
              "It's me, Kero!",
              "I hope you had a good day with me at your party",
              "I just wanted to tell you .....",
              "Happy Birthday to my fav Faroh 🥳🥳🥳",
              "You are a good person, with a good heart🤍",
              "And I really enjoy talking to you, having good times with you",
              "and even bothering you 😜",
              "May God bless you and give you a life full of happiness for eternity",
              "I wish all your dreams come true",
              "This is my special gift for you that no one had and no one will",
              "A special gift for a special one",
              "I tried my best to make it useful, usable, and precious",
              "Now let's see what my app for you can do!",
              ""
            ][index],
            isLastPage: index == 13,
            showHint: index == 0,
            onComplete: _completeOnboarding,
          );
        }),
      ),
    );
  }
}

class OnBoardingPageContent extends StatelessWidget {
  final Color color;
  final String description;
  final bool isLastPage;
  final bool showHint;
  final VoidCallback? onComplete;

  const OnBoardingPageContent({
    required this.color,
    required this.description,
    this.isLastPage = false,
    this.showHint = false,
    this.onComplete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1,
                  ),
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.07,
                      color: Colors.white,
                      fontFamily: 'Teko',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (isLastPage)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: onComplete,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Get Started'),
                    ),
                  ),
              ],
            ),
          ),
          if (showHint)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Text(
                'Swipe to continue',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  color: Colors.white.withOpacity(0.8),
                  fontFamily: 'Teko',
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String farahHub = '/hub';
}

