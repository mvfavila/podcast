import 'package:flutter/material.dart';

import 'package:podcast/data_model/episode.dart';

List<Episode> mockEpisodes = [
  Episode(
    id: '1',
    title: 'Latest Flutter News',
    podcastName: 'Flutter Weekly',
    publicationDate: DateTime.now().subtract(Duration(hours: 3)),
  ),
  Episode(
    id: '2',
    title: 'Golang Patterns',
    podcastName: 'Go Dev Talk',
    publicationDate: DateTime.now().subtract(Duration(hours: 10)),
    isPlayed: true,
  ),
  Episode(
    id: '3',
    title: 'Firebase Best Practices',
    podcastName: 'Tech Trends',
    publicationDate: DateTime.now().subtract(Duration(days: 1)),
  ),
  // Add more episodes
];

class NewEpisodesScreen extends StatefulWidget {
  const NewEpisodesScreen({super.key});

  @override
  NewEpisodesScreenState createState() => NewEpisodesScreenState();
}

class NewEpisodesScreenState extends State<NewEpisodesScreen> {
  late List<Episode> _episodes;

  @override
  void initState() {
    super.initState();
    _episodes = mockEpisodes;  // Simulating initial data
  }

  // Refresh the episode list when the user pulls down
  Future<void> _refreshEpisodes() async {
    // Here, fetch new episodes from the server (Firebase, Spotify API, etc.)
    setState(() {
      _episodes = mockEpisodes;  // Refresh the episode list
    });
  }

  // Toggle episode in playlist
  void _toggleInPlaylist(Episode episode) {
    setState(() {
      episode.isInPlaylist = !episode.isInPlaylist;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sort episodes by publication date
    _episodes.sort((a, b) => b.publicationDate.compareTo(a.publicationDate));

    return Scaffold(
      appBar: AppBar(title: Text('New Episodes')),
      body: RefreshIndicator(
        onRefresh: _refreshEpisodes,
        child: ListView.builder(
          itemCount: _episodes.length,
          itemBuilder: (context, index) {
            final episode = _episodes[index];
            return ListTile(
              title: Text(
                episode.title,
                style: TextStyle(
                  color: episode.isPlayed ? Colors.grey : Colors.black,
                ),
              ),
              subtitle: Text(episode.podcastName),
              trailing: IconButton(
                icon: Icon(
                  episode.isInPlaylist ? Icons.playlist_add_check : Icons.playlist_add,
                  color: episode.isInPlaylist ? Colors.green : Colors.black,
                ),
                onPressed: () => _toggleInPlaylist(episode),
              ),
              onTap: () {
                // Open the episode player, or mark as played
                setState(() {
                  episode.isPlayed = true;
                });
              },
            );
          },
        ),
      ),
    );
  }
}