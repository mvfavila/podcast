import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:podcast/feature/search/podcast_search_screen.dart';
import 'package:podcast/login_screen.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to the podcast client app, ${user.displayName}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the PodcastSearchScreen when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PodcastSearchScreen()),
                );
              },
              child: const Text('Search Podcasts'),
            ),
          ],
        ),
      ),
    );
  }
}