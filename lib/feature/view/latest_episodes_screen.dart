import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

import 'package:podcast/data_model/episode.dart';
import 'package:podcast/feature/view/building_blocks/episode_tile.dart';
import 'package:podcast/vendor/remote_config_service.dart';
import 'package:podcast/vendor/spotify_service.dart';

class LatestEpisodesScreen extends StatefulWidget {
  const LatestEpisodesScreen({super.key});

  @override
  LatestEpisodesScreenState createState() => LatestEpisodesScreenState();
}

class LatestEpisodesScreenState extends State<LatestEpisodesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Episode> _episodes = [];
  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _syncAndFetchEpisodes();
  }

  Future<void> _syncAndFetchEpisodes() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final subscriptions = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('subscriptions')
          .get();

      List<Episode> episodes = [];

      for (var doc in subscriptions.docs) {
        final podcastId = doc.id;
        final newEpisodes = await _fetchEpisodesFromSpotify(podcastId);
        episodes.addAll(newEpisodes);
      }

      await _updateEpisodeStates(episodes);

      setState(() {
        episodes.sort((a, b) {
          if (a.releaseDate == null && b.releaseDate == null) return 0;
          if (a.releaseDate == null) return -1;
          if (b.releaseDate == null) return 1;
          
          return b.releaseDate!.compareTo(a.releaseDate!);
        });

        _episodes = episodes;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Episode>> _fetchEpisodesFromSpotify(String podcastId) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    final remoteConfigService = RemoteConfigService(remoteConfig);
    SpotifyService spotifyService = SpotifyService(remoteConfigService);

    final episodeData = await spotifyService.getPodcastEpisodes(podcastId, limit: 5);

    if (episodeData == null) {
      // Handle the case where no data was returned
      // TODO: log error message
      return [];
    }

    final List<Episode> result = [];
    episodeData['items'].forEach((item) {
      result.add(Episode(
        id: item['id'],
        name: item['name'],
        description: item['description'],
        releaseDate: DateTime.parse(item['release_date']),
        imageUrl: item['images'][0]['url'],
      ));
    });
    return result;
  }

  Future<void> _updateEpisodeStates(List<Episode> episodes) async {
    final userId = _currentUser!.uid;

    // Fetch played episodes
    final playedSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('episodesCompleted')
        .get();

    final playedEpisodeIds = playedSnapshot.docs.map((doc) => doc.id).toSet();

    // Fetch playlist episodes
    final playlistSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('playlist')
        .get();

    final playlistEpisodeIds = playlistSnapshot.docs.map((doc) => doc.id).toSet();

    // Update each episode's played and playlist status
    for (var episode in episodes) {
      episode.isPlayed = playedEpisodeIds.contains(episode.id);
      episode.isInPlaylist = playlistEpisodeIds.contains(episode.id);
    }
  }

  Future<void> _toggleInPlaylist(Episode episode) async {
    final userId = _currentUser!.uid;
    final playlistRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('playlist')
        .doc(episode.id);

    setState(() {
      episode.isInPlaylist = !episode.isInPlaylist;
    });

    if (episode.isInPlaylist) {
      await playlistRef.set(episode.toJson());
    } else {
      await playlistRef.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Latest Episodes')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())  // Show loading indicator
          : RefreshIndicator(
              onRefresh: _syncAndFetchEpisodes,
              child: ListView.builder(
                itemCount: _episodes.length,
                itemBuilder: (context, index) {
                  final episode = _episodes[index];
                  return EpisodeTile(
                    episode: episode,
                    backupImageUrl: 'path_to_default_image', // Replace with your backup image URL
                    onToggleInPlaylist: _toggleInPlaylist,
                  );
                },
              ),
            ),
    );
  }
}