import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'lessons-cotroller.dart';
import 'speak_mate/pages/speak_mate_page.dart';

class LessonScreen extends StatelessWidget {
  final LessonController _controller = Get.put(LessonController());

  LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen dimensions for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.pink.shade800,
      appBar: AppBar(
        title: Text(
          'Lessons of the day',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.06, // Scaled font size
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.pink.shade900,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              FontAwesomeIcons.comments,
              color: Colors.white,
            ),
            tooltip: 'SpeakMate - Practice Speaking',
            onPressed: () {
              Get.to(() => SpeakMatePage(),
                  transition: Transition.rightToLeft,
                  duration: Duration(milliseconds: 300));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => SpeakMatePage(),
              transition: Transition.rightToLeft,
              duration: Duration(milliseconds: 300));
        },
        backgroundColor: Colors.pink.shade900,
        icon: Icon(FontAwesomeIcons.microphone),
        label: Text('Practice Speaking'),
      ),
      body: Obx(() {
        if (!_controller.isLessonAvailable.value) {
          return Center(
            child: FadeIn(
              child: Text(
                'No lessons today! 😊',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.07, // Scaled font size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(screenWidth * 0.04), // Scaled padding
          itemCount: _controller.dailyLessons.length,
          itemBuilder: (context, index) {
            final lesson = _controller.dailyLessons[index];
            return ZoomIn(
              delay: Duration(milliseconds: 200 * index),
              child: Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.02), // Scaled margin
                decoration: BoxDecoration(
                  color: Color(0xffedf3ff),
                  borderRadius: BorderRadius.circular(screenWidth * 0.05), // Scaled border radius
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: screenWidth * 0.03, // Scaled blur radius
                      offset: Offset(0, screenHeight * 0.005), // Scaled offset
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04), // Scaled padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // English Word
                      ElasticIn(
                        child: Text(
                          lesson.englishWord,
                          style: TextStyle(
                            fontSize: screenWidth * 0.08, // Scaled font size
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade800,
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.01), // Scaled spacing

                      // Arabic Translation
                      FadeInLeft(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: screenWidth * 0.06, // Scaled font size
                              color: Colors.black87,
                            ),
                            children: [
                              TextSpan(
                                text: 'Arabic: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: lesson.arabicTranslation),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02), // Scaled spacing

                      // Phrase
                      FadeInRight(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: screenWidth * 0.046, // Scaled font size
                              color: Colors.black87,
                              fontStyle: FontStyle.italic,
                            ),
                            children: [
                              TextSpan(
                                text: 'Phrase: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: lesson.phrase),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02), // Scaled spacing

                      // Explanation
                      FadeInUp(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: screenWidth * 0.05, // Scaled font size
                              color: Colors.black54,
                            ),
                            children: [
                              TextSpan(
                                text: 'Explanation: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: lesson.explanation),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
