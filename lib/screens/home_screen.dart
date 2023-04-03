import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/validator.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_textformfield.dart';
import './sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? _auth = FirebaseAuth.instance.currentUser;

  bool isLoading = false;

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  final _formKey = GlobalKey<FormState>();

  late String? _name;
  late String? _email;
  late String? _profileImage;
  late bool _isEmailVerified;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _imageController = TextEditingController();

  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _imageFocusNode = FocusNode();

  @override
  void initState() {
    _name = _auth?.displayName ?? '';
    _email = _auth?.email ?? '';
    _profileImage = _auth?.photoURL ?? '';
    _isEmailVerified = _auth?.emailVerified ?? false;

    _usernameController.text = _name!;
    _emailController.text = _email!;
    _imageController.text = _profileImage!;
    super.initState();
  }

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _imageFocusNode.dispose();
    super.dispose();
  }

  Future<void> onTapUpdate(context) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setIsLoading();
      try {
        await _auth!.updateDisplayName(_usernameController.text.trim());
        await _auth!.updateEmail(_emailController.text.trim());
        await _auth!.updatePhotoURL(_imageController.text.trim());

        setState(() {
          _name = _usernameController.text.trim();
          _email = _emailController.text.trim();
          _profileImage = _imageController.text.trim();
        });
        CustomScaffoldSnackbar.of(context)
            .show('Profile Update successful!', SnackBarType.success);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-email') {
          CustomScaffoldSnackbar.of(context).show(
              'The email address is malformed or otherwise invalid',
              SnackBarType.error);
        } else if (e.code == 'email-already-in-use') {
          CustomScaffoldSnackbar.of(context)
              .show('Email is already taken', SnackBarType.error);
        } else if (e.code == 'network-request-failed') {
          CustomScaffoldSnackbar.of(context).show(
              'An error occurred. Please check your internet connection and try again',
              SnackBarType.error);
        }
        print(e);
      } catch (e) {
        CustomScaffoldSnackbar.of(context).show(
            'Profile update failed. Please try again later.',
            SnackBarType.error);
        print(e);
      }
      setIsLoading();
    }
  }

  Future<void> _sendVerification(context) async {
    await _auth!.sendEmailVerification();
    CustomScaffoldSnackbar.of(context).show(
      'Verification email sent. Please check your inbox.',
      SnackBarType.success,
    );
  }

  void onTapDeleteAccount(context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
            'Are you sure you want to delete this account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser?.delete();
                CustomScaffoldSnackbar.of(context).show(
                  'Your account has been deleted successfully!',
                  SnackBarType.success,
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (route) => false,
                );
              } on FirebaseAuthException catch (e) {
                CustomScaffoldSnackbar.of(context).show(
                  'Failed to delete your account. ${e.message}',
                  SnackBarType.error,
                );
              }
            },
            child: const Text('Yes, Delete'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Profile",
          style: TextStyle(color: Colors.deepPurple),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height +
                  80 -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                        Colors.lightBlue, BlendMode.color),
                    child: CachedNetworkImage(
                      imageUrl: _profileImage!,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              CachedNetworkImageProvider(_profileImage!),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _name!,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _email!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Column(
                          children: [
                            CustomTextFormField(
                              controller: _usernameController,
                              focusNode: _usernameFocusNode,
                              labelText: 'Name',
                              suffixIcon:
                                  const Icon(Icons.person_outline_rounded),
                              keyboardType: TextInputType.name,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_emailFocusNode);
                              },
                              validator: (value) =>
                                  Validator.validateName(value!),
                            ),
                            CustomTextFormField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              labelText: 'Email',
                              suffixIcon:
                                  const Icon(Icons.alternate_email_rounded),
                              keyboardType: TextInputType.emailAddress,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_imageFocusNode);
                              },
                              validator: (value) =>
                                  Validator.validateEmail(value!),
                            ),
                            if (!_isEmailVerified)
                              Container(
                                margin: const EdgeInsets.only(top: 24),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'You have not verified your email. Please check your inbox and verify your email address.',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _sendVerification(context),
                                      child: const Text('Send Verification'),
                                    ),
                                  ],
                                ),
                              ),
                            CustomTextFormField(
                              controller: _imageController,
                              focusNode: _imageFocusNode,
                              labelText: 'Photo URL',
                              suffixIcon: const Icon(Icons.link),
                              keyboardType: TextInputType.url,
                              onFieldSubmitted: (_) => onTapUpdate(context),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'The Photo URL Cannot be empty.';
                                }
                                return null;
                              },
                            ),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 24),
                              child: CustomElevatedButton(
                                isLoading: isLoading,
                                onPressed: () => onTapUpdate(context),
                                text: 'Update Profile',
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 4),
                              child: ElevatedButton(
                                onPressed: () {
                                  FirebaseAuth.instance.signOut();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignInScreen(),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.error),
                                ),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 4),
                              child: ElevatedButton(
                                onPressed: () => onTapDeleteAccount(context),
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.error),
                                ),
                                child: const Text(
                                  'Delete My Account',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
