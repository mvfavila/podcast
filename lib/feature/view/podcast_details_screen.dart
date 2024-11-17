import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

import 'package:podcast/data_model/episode.dart';
import 'package:podcast/feature/view/building_blocks/episode_tile.dart';
import 'package:podcast/vendor/remote_config_service.dart';
import 'package:podcast/vendor/spotify_service.dart';

class PodcastDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> podcast;

  const PodcastDetailsScreen({super.key, required this.podcast});

  @override
  PodcastDetailsScreenState createState() => PodcastDetailsScreenState();
}

class PodcastDetailsScreenState extends State<PodcastDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final descriptionShortenedLength = 150;

  Map<String, dynamic>? _podcastDetails;
  bool _isLoading = true;
  bool _isDescriptionExpanded = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _fetchPodcastDetails();
  }

  void _fetchPodcastDetails() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    final remoteConfigService = RemoteConfigService(remoteConfig);
    SpotifyService spotifyService = SpotifyService(remoteConfigService);
    
    final details = await spotifyService.getPodcastDetails(widget.podcast['id']);
    setState(() {
      _podcastDetails = details;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.podcast['name']),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.podcast['image_url'] != null)
                    Center(
                      child: Image.network(widget.podcast['image_url'], height: 180, width: 180),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    'Publisher: ${widget.podcast['publisher']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  if (_podcastDetails != null)
                    _buildDescriptionSection(_podcastDetails!['description']),
                  const SizedBox(height: 20),
                  const Text(
                    'Episodes:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: _podcastDetails != null
                        ? ListView.builder(
                            itemCount: _podcastDetails!['episodes']['items'].length,
                            itemBuilder: (context, index) {
                              final episode = _podcastDetails!['episodes']['items'][index];
                              return EpisodeTile(episode: Episode.fromJson(episode['id'], episode), backupImageUrl: widget.podcast['image_url'], onToggleInPlaylist: _toggleInPlaylist);
                            },
                          )
                        : const Text('No episodes available'),
                  ),
                ],
              ),
            ),
    );
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
      await playlistRef.set({
        'title': episode.name,
      });
    } else {
      await playlistRef.delete();
    }
  }



  Widget _buildDescriptionSection(String description) {
    bool isLongDescription = description.length > 150;
    String displayDescription = _isDescriptionExpanded || !isLongDescription
        ? description
        : '${description.substring(0, 150)}... ';

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black),
        children: [
          TextSpan(
            text: displayDescription,
          ),
          if (isLongDescription)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isDescriptionExpanded = !_isDescriptionExpanded;
                  });
                },
                child: Text(
                  _isDescriptionExpanded ? ' Show less' : ' Show more',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
