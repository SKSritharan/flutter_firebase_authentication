import 'package:flutter/material.dart';
import 'package:flutter_firebase_authentication/widgets/custom_image_picker.dart';

import '../utils/validator.dart';
import '../widgets/custom_textformfield.dart';
import './sign_in_screen.dart';
import './home_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/register';
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = true;

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _userImage = 'assets/images/default_user.png';

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onTapSubmit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
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
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize:
                            Theme.of(context).textTheme.titleLarge?.fontSize,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2.0,
                      ),
                    ),
                    child: CustomImagePicker(
                      defaultImage: Image.asset(_userImage),
                      onImageSelected: (value) {
                        setState(() {
                          _userImage = value;
                        });
                      },
                    ),
                  ),
                  CustomTextFormField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    labelText: 'Name',
                    suffixIcon: const Icon(Icons.person_outline_rounded),
                    keyboardType: TextInputType.name,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_emailFocusNode);
                    },
                    validator: (value) => Validator.validateName(value!),
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
                    onFieldSubmitted: (_) => _onTapSubmit(),
                    validator: (value) => Validator.validatePassword(value!),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 24),
                    child: ElevatedButton(
                      onPressed: () => _onTapSubmit(),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Signup",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushReplacementNamed(SignInScreen.routeName);
                    },
                    child: Container(
                      padding: const EdgeInsets.only(top: 128, bottom: 8),
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            const TextSpan(
                              text: "I already have an account? ",
                              style: TextStyle(color: Colors.black54),
                            ),
                            TextSpan(
                              text: "Sign In",
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
