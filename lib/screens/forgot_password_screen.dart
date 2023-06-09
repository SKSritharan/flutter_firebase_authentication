import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/validator.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_textformfield.dart';
import './sign_up_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgot-password';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool isLoading = false;

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onTapSubmit(context) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _emailController.text.trim());
        CustomScaffoldSnackbar.of(context).show(
            'Password reset email sent. Please check your inbox.',
            SnackBarType.success);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          CustomScaffoldSnackbar.of(context).show(
              'No user found with that email. Please check the email address and try again.',
              SnackBarType.error);
        } else if (e.code == 'invalid-email') {
          CustomScaffoldSnackbar.of(context).show(
              'The email address is invalid. Please enter a valid email address and try again.',
              SnackBarType.error);
        } else {
          CustomScaffoldSnackbar.of(context).show(
              'An error occurred while sending the password reset email. Please try again later.',
              SnackBarType.error);
        }
      } catch (e) {
        CustomScaffoldSnackbar.of(context).show(
            'An error occurred while sending the password reset email. Please try again later.',
            SnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            ClipPath(
              clipper: _MyCustomClipper(context),
              child: Container(
                alignment: Alignment.center,
              ),
            ),
            Positioned(
              left: 30,
              right: 30,
              top: MediaQuery.of(context).size.height * 0.15,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 8,
                    ),
                    child: Text(
                      "Forgot Password",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize:
                            Theme.of(context).textTheme.titleLarge?.fontSize,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      "Enter the email address associated with your account and we will send you a link to reset your password.",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium?.fontSize,
                      ),
                    ),
                  ),
                  CustomTextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    labelText: 'Email',
                    suffixIcon: const Icon(Icons.alternate_email_rounded),
                    keyboardType: TextInputType.emailAddress,
                    onFieldSubmitted: (_) => _onTapSubmit(context),
                    validator: (value) => Validator.validateEmail(value!),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 24),
                    child: ElevatedButton(
                      onPressed: () => _onTapSubmit(context),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Send",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushReplacementNamed(SignUpScreen.routeName);
                    },
                    child: Container(
                      padding: const EdgeInsets.only(top: 128, bottom: 8),
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            const TextSpan(
                              text: "Don't have an account yet? ",
                              style: TextStyle(color: Colors.black54),
                            ),
                            TextSpan(
                              text: "Sign Up",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _MyCustomClipper extends CustomClipper<Path> {
  final BuildContext _context;

  _MyCustomClipper(this._context);

  @override
  Path getClip(Size size) {
    final path = Path();
    Size size = MediaQuery.of(_context).size;
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.3);
    path.lineTo(0, size.height * 0.6);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}
