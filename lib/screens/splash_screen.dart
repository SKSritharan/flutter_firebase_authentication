import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './home_screen.dart';
import './sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.repeat(reverse: true);

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Future.delayed(const Duration(seconds: 3)).then((value) {
          Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
        });
      } else {
        Future.delayed(const Duration(seconds: 3)).then((value) {
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 50.0,
              width: 50.0,
              child: CachedNetworkImage(
                imageUrl:
                    'https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_28dp.png',
                    fit: BoxFit.cover,
              ),
            ),
            FadeTransition(
              opacity: _animation,
              child: const Text(
                'Firebase Authentication',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: Colors.amber),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
