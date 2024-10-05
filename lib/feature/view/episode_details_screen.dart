import 'package:flutter/material.dart';

class EpisodeDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> episode;

  const EpisodeDetailsScreen({super.key, required this.episode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(episode['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (episode['images'] != null && episode['images'].isNotEmpty)
              Center(
                child: Image.network(episode['images'][0]['url'], height: 200, width: 200),
              ),
            const SizedBox(height: 20),
            Text(
              episode['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Release Date: ${episode['release_date']}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              episode['description'] ?? 'No description available',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}