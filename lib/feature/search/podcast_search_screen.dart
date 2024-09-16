import 'package:flutter/material.dart';

import 'package:podcast/vendor/spotify_service.dart';

class PodcastSearchScreen extends StatefulWidget {
  const PodcastSearchScreen({super.key});

  @override
  PodcastSearchScreenState createState() => PodcastSearchScreenState();
}

class PodcastSearchScreenState extends State<PodcastSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic>? _podcasts;
  bool _isLoading = false;

  void _searchPodcasts() async {
    setState(() {
      _isLoading = true;
    });

    SpotifyService spotifyService = SpotifyService();
    final podcasts = await spotifyService.searchPodcasts(_controller.text);

    setState(() {
      _podcasts = podcasts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Podcasts')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _searchPodcasts,
            child: const Text('Search'),
          ),
          if (_isLoading) const CircularProgressIndicator(),
          Expanded(
            child: _podcasts == null
                ? const Text('No results')
                : ListView.builder(
                    itemCount: _podcasts!.length,
                    itemBuilder: (context, index) {
                      final podcast = _podcasts![index];
                      return ListTile(
                        title: Text(podcast['name']),
                        subtitle: Text(podcast['publisher']),
                        leading: podcast['images'].isNotEmpty
                            ? Image.network(podcast['images'][0]['url'])
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
