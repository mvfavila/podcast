import 'package:flutter/material.dart';

import 'package:podcast/data_model/episode.dart';
import 'package:podcast/feature/view/episode_details_screen.dart';

class EpisodeTile extends StatelessWidget {
  final Episode episode;
  final String backupImageUrl;
  final Function(Episode episode) onToggleInPlaylist;

  const EpisodeTile({super.key, required this.episode, required this.backupImageUrl, required this.onToggleInPlaylist});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      dense: true,
      leading: Image.network(
        episode.imageUrl != '' ? episode.imageUrl : backupImageUrl,
        height: 60,
        width: 60,
        fit: BoxFit.cover,
      ),
      title: Text(
        episode.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        episode.publicationDate.toString(),
        style: TextStyle(fontSize: 12),
      ),
      trailing: IconButton(
        icon: Icon(
          episode.isInPlaylist ? Icons.playlist_add_check : Icons.playlist_add,
          color: episode.isInPlaylist ? Colors.green : Colors.black,
        ),
        onPressed: () => onToggleInPlaylist(episode),
      ),
      onTap: () {
        // Navigate to EpisodeDetailsScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EpisodeDetailsScreen(episode: episode),
          ),
        );
      },
    );
  }

  factory EpisodeTile.fromEpisode(Episode episode, Function(Episode) onToggleInPlaylist) {
    return EpisodeTile(
      episode: episode,
      backupImageUrl: episode.imageUrl,
      onToggleInPlaylist: onToggleInPlaylist,
    );
  }
}