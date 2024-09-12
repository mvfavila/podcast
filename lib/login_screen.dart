import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // Import Crashlytics

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;
  String? _errorMessage;

  // Method to handle Google Sign-In with enhanced logging to Firebase Crashlytics
  Future<User?> _handleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return null; // User aborted the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      setState(() {
        _isLoading = false;
      });
      return userCredential.user;
    } on FirebaseAuthException catch (e, stackTrace) {
      _logFirebaseAuthError(e, stackTrace);  // Log Firebase-specific errors
      setState(() {
        _isLoading = false;
        _errorMessage = handleFirebaseAuthError(e);  
      });
    } on SocketException catch (e, stackTrace) {
      _logError('Network error', e, stackTrace);  // Log network errors
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network error. Please check your internet connection and try again.';
      });
    } catch (error, stackTrace) {
      _logError('Unexpected error during sign-in', error, stackTrace);  // Log any other errors
      setState(() {
        _isLoading = false;
        _errorMessage = 'Something went wrong. Please try again later.';
      });
    }

    return null;
  }

  // Log Firebase-specific authentication errors to Crashlytics
  void _logFirebaseAuthError(FirebaseAuthException e, StackTrace stackTrace) {
    // Log to Firebase Crashlytics
    FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Firebase Auth Error: ${e.code}');
  }

  // General error logging function
  void _logError(String message, dynamic error, StackTrace stackTrace) {
    // Log to Firebase Crashlytics
    FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign in"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isLoading)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton(
                onPressed: () async {
                  User? user = await _handleSignIn();
                  if (user != null && context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen(user)),
                    );
                  }
                },
                child: const Text('Sign in with Google'),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      if (_errorMessage != 'Something went wrong. Please try again later.')
                        ElevatedButton(
                          onPressed: () {
                            _handleSignIn();
                          },
                          child: const Text('Retry'),
                        )
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

String handleFirebaseAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'account-exists-with-different-credential':
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-disabled':
    case 'user-not-found':
      return 'Incorrect user/password. Please try again.';
    case 'operation-not-allowed':
      return 'Sign-in with Google is not enabled.';
    default:
      return 'An unknown error occurred. Please try again later.';
  }
}

class HomeScreen extends StatelessWidget {
  final User user;

  const HomeScreen(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user.displayName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              GoogleSignIn().signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          )
        ],
      ),
      body: Center(
        child: Text('Welcome to the podcast client app, ${user.displayName}'),
      ),
    );
  }
}
