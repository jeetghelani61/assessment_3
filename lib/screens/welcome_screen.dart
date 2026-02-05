// screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_button.dart';
import 'login_screen.dart';


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _showIntro = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _showSplash();
  }

  void _showSplash() async {
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _showIntro = true;
    });
  }

  void _completeIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_showIntro) {
      return const SplashScreen();
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  IntroSlide(
                    image: 'assets/images/slide1.png', // Add your image
                    title: 'Discover Amazing Events',
                    description: 'Find and join exciting events happening around you',
                  ),
                  IntroSlide(
                    image: 'assets/images/slide2.png',
                    title: 'Easy Registration',
                    description: 'Register for events with just one click',
                  ),
                  IntroSlide(
                    image: 'assets/images/slide3.png',
                    title: 'Manage Your Events',
                    description: 'Keep track of all your registered events',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Colors.deepPurple
                              : Colors.grey[300],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 30),
                  if (_currentPage == 2)
                    CustomButton(
                      text: 'Get Started',
                      onPressed: _completeIntro,
                      width: double.infinity,
                    ),
                  if (_currentPage != 2)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _completeIntro,
                          child: const Text('Skip'),
                        ),
                        IconButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Image.asset(
             'assets/intro/event.png',
              width: 120,
              height: 120,
              // color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'EventBuzz',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IntroSlide extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const IntroSlide({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}