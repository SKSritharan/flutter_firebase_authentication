import 'package:flutter/material.dart';

class SignInScreen extends StatelessWidget {
  static const String routeName = '/login';
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Sign In Screen'),
      ),
    );
  }
}
