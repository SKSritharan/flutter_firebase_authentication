import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/validator.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_textformfield.dart';
import './forgot_password_screen.dart';
import './sign_up_screen.dart';
import './home_screen.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/login';
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = true;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onTapSubmit(context) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setIsLoading();
      try {
        await auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        CustomScaffoldSnackbar.of(context)
            .show('Login Success!', SnackBarType.success);
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          CustomScaffoldSnackbar.of(context).show(
              'There is no user record corresponding to this email address',
              SnackBarType.error);
        } else if (e.code == 'wrong-password') {
          CustomScaffoldSnackbar.of(context)
              .show('The password is invalid', SnackBarType.error);
        } else if (e.code == 'network-request-failed') {
          CustomScaffoldSnackbar.of(context).show(
              'An error occurred. Please check your internet connection and try again',
              SnackBarType.error);
        }
      } catch (e) {
        CustomScaffoldSnackbar.of(context)
            .show('Login failed. Please try again later.', SnackBarType.error);
      }
      setIsLoading();
    }
  }

  Future<void> signInWithGoogle(context) async {
    setIsLoading();
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);
      CustomScaffoldSnackbar.of(context)
          .show('Signed in successfully', SnackBarType.success);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        CustomScaffoldSnackbar.of(context).show(
            'The email is already associated with another account',
            SnackBarType.error);
      } else if (e.code == 'invalid-credential') {
        CustomScaffoldSnackbar.of(context)
            .show('Error signing in. Invalid credentials', SnackBarType.error);
      }
      print(e);
    } catch (e) {
      CustomScaffoldSnackbar.of(context)
          .show('Error signing in. Please try again', SnackBarType.error);
      print(e);
    }
    setIsLoading();
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
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize:
                            Theme.of(context).textTheme.titleLarge?.fontSize,
                      ),
                    ),
                  ),
                  CustomTextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    labelText: 'Email',
                    suffixIcon: const Icon(Icons.alternate_email_rounded),
                    keyboardType: TextInputType.emailAddress,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                    validator: (value) => Validator.validateEmail(value!),
                  ),
                  CustomTextFormField(
                    controller: _passwordController,
                    obscureText: _passwordVisible,
                    focusNode: _passwordFocusNode,
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.lock_outline_rounded
                            : Icons.lock_open_rounded,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.visiblePassword,
                    onFieldSubmitted: (_) => _onTapSubmit(context),
                    validator: (value) => Validator.validatePassword(value!),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(ForgotPasswordScreen.routeName);
                    },
                    child: Container(
                      padding: const EdgeInsets.only(top: 8),
                      alignment: Alignment.topRight,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 24),
                    child: CustomElevatedButton(
                      isLoading: isLoading,
                      onPressed: () => _onTapSubmit(context),
                      text: 'Login',
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 4),
                    child: ElevatedButton(
                      onPressed:
                          isLoading ? null : () => signInWithGoogle(context),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        backgroundColor:
                            const MaterialStatePropertyAll(Colors.white),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                                strokeWidth: 3,
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: 36,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  isLoading
                                      ? const CircularProgressIndicator()
                                      : CachedNetworkImage(
                                          imageUrl:
                                              'http://pngimg.com/uploads/google/google_PNG19635.png',
                                          fit: BoxFit.cover),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  const Text(
                                    "Sign in with Google",
                                    style: TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
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
