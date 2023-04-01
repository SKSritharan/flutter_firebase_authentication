import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  static const String routeName = '/register';
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Sign Up Screen'),
      ),
    );
  }
}
