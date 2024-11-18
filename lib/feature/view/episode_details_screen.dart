import 'package:flutter/material.dart';

import 'package:podcast/data_model/episode.dart';

class EpisodeDetailsScreen extends StatelessWidget {
  final Episode episode;

  const EpisodeDetailsScreen({super.key, required this.episode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(episode.name),
      ),
      body: SingleChildScrollView( // Wrap content in SingleChildScrollView to avoid overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(episode.imageUrl, height: 200, width: 200),
            ),
            const SizedBox(height: 20),
            Text(
              episode.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Release Date: ${episode.releaseDate.toString()}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              episode.description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}