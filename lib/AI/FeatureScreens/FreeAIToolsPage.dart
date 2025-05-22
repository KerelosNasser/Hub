import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class FreeAIToolsPage extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Chats',
      'icon': FontAwesomeIcons.comments,
      'tools': [
        {
          'name': 'ChatGPT',
          'description': 'AI conversational assistant by OpenAI.',
          'url': 'https://chat.openai.com/',
          'icon': FontAwesomeIcons.robot,
        },
        {
          'name': 'Claude',
          'description': 'AI assistant by Anthropic.',
          'url': 'https://www.anthropic.com/index/claude',
          'icon': FontAwesomeIcons.brain,
        },
        {
          'name': 'Microsoft Copilot',
          'description': 'AI assistant by Microsoft that generates image.',
          'url': 'https://copilot.microsoft.com/',
          'icon': FontAwesomeIcons.microsoft,
        },
        {
          'name': 'Gemini',
          'description': 'Google’s generative AI chatbot.',
          'url': 'https://gemini.google.com/app',
          'icon': FontAwesomeIcons.google,
        },
      ],
    },
    {
      'title': 'Photo Editing',
      'icon': FontAwesomeIcons.images,
      'tools': [
        {
          'name': 'PhotoRoom',
          'description': 'Remove unwanted objects in photos.',
          'url': 'https://www.photoroom.com/tools/remove-object-from-photo',
          'icon': FontAwesomeIcons.film,
        },
        {
          'name': 'Cutout Pro',
          'description': 'Improve image quality.',
          'url': 'https://www.cutout.pro/photo-enhancer-sharpener-upscaler',
          'icon': FontAwesomeIcons.star,
        },
        {
          'name': 'Picsart',
          'description': 'Expand your image dimensions.',
          'url': 'https://picsart.com/ai-image-extender/',
          'icon': FontAwesomeIcons.bookmark,
        },
      ],
    },
    {
      'title': 'Image Generators',
      'icon': FontAwesomeIcons.paintbrush,
      'tools': [
        {
          'name': 'Davinci AI',
          'description': 'Advanced AI image generator.',
          'url': 'https://davinci.ai/',
          'icon': FontAwesomeIcons.droplet,
        },
        {
          'name': 'DALL·E 2',
          'description': 'AI-powered image generation.',
          'url': 'https://openai.com/dall-e',
          'icon': FontAwesomeIcons.image,
        },
        {
          'name': 'Craiyon',
          'description': 'Collaborative AI art creation.',
          'url': 'https://www.craiyon.com/',
          'icon': FontAwesomeIcons.palette,
        },
      ],
    },
    {
      'title': 'Animation Tools',
      'icon': FontAwesomeIcons.video,
      'tools': [
        {
          'name': 'Lumen5',
          'description': 'Best AI video generator.',
          'url': 'https://lumen5.com/',
          'icon': FontAwesomeIcons.faceSmile,
        },
        {
          'name': 'Runway ML',
          'description': 'Create videos using AI.',
          'url': 'https://runwayml.com/',
          'icon': FontAwesomeIcons.film,
        },
        {
          'name': 'Animaker',
          'description': 'Online animation maker.',
          'url': 'https://www.animaker.com/',
          'icon': FontAwesomeIcons.play,
        },
      ],
    },
    {
      'title': 'Voice Changing Tools',
      'icon': FontAwesomeIcons.microphone,
      'tools': [
        {
          'name': 'Voicemod',
          'description': 'Real-time voice changer.',
          'url': 'https://www.voicemod.net/',
          'icon': FontAwesomeIcons.volumeUp,
        },
        {
          'name': 'MorphVox',
          'description': 'AI-based voice modification.',
          'url': 'https://screamingbee.com/',
          'icon': FontAwesomeIcons.headphones,
        },
      ],
    },
    {
      'title': 'Others',
      'icon': FontAwesomeIcons.bots,
      'tools': [
        {
          'name': 'RemoveBG',
          'description': 'Remove background from images.',
          'url': 'https://www.remove.bg/',
          'icon': FontAwesomeIcons.clone,
        },
        {
          'name': 'Perplexity',
          'description': 'For online research.',
          'url': 'https://www.perplexity.ai/',
          'icon': FontAwesomeIcons.bookmark,
        },
        {
          'name': 'Humanizer',
          'description': 'Make your research more human-like.',
          'url': 'https://www.humanizeai.pro/',
          'icon': FontAwesomeIcons.personCircleCheck,
        },
      ],
    },
  ];

  FreeAIToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.pink.shade800,
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.05,
            ),
            child: _buildCategoryCard(category, screenWidth),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, double screenWidth) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xffedf3ff),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  category['icon'],
                  size: screenWidth * 0.1,
                  color: Colors.pink.shade800,
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Text(
                    category['title'],
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade800,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.04),
            Column(
              children: (category['tools'] as List).map((tool) {
                return _buildToolCard(tool, screenWidth);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(Map<String, dynamic> tool, double screenWidth) {
    return Animate(
      effects: [
        FadeEffect(duration: 600.ms),
        SlideEffect(begin: const Offset(0, 0.2))
      ],
      child: Card(
        color: const Color(0xffedf3ff),
        margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 10,
        child: ListTile(
          leading: Icon(
            tool['icon'],
            color: Colors.pink.shade800,
            size: screenWidth * 0.08,
          ),
          title: Text(
            tool['name'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.045,
            ),
          ),
          subtitle: Text(
            tool['description'],
            style: TextStyle(fontSize: screenWidth * 0.04),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.launch,
              color: Colors.pink,
              size: screenWidth * 0.06,
            ),
            onPressed: () => _launchURL(tool['url']),
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
