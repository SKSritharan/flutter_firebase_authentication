import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase_authentication/screens/forgot_password_screen.dart';

import './screens/sign_in_screen.dart';
import './screens/sign_up_screen.dart';
import './screens/splash_screen.dart';
import './screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Authentication',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Lato',
      ),
      home: const SplashScreen(),
      routes: {
        SignInScreen.routeName: (ctx) => const SignInScreen(),
        ForgotPasswordScreen.routeName: (ctx) => const ForgotPasswordScreen(),
        SignUpScreen.routeName: (ctx) => const SignUpScreen(),
        HomeScreen.routeName: (ctx) => const HomeScreen(),
      },
    );
  }
}
