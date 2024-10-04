import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'package:podcast/vendor/remote_config_service.dart';
import 'package:podcast/vendor/spotify_service.dart';

class PodcastDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> podcast;

  const PodcastDetailsScreen({super.key, required this.podcast});

  @override
  PodcastDetailsScreenState createState() => PodcastDetailsScreenState();
}

class PodcastDetailsScreenState extends State<PodcastDetailsScreen> {
  final descriptionShortenedLength = 150;

  Map<String, dynamic>? _podcastDetails;
  bool _isLoading = true;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
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
              padding: const EdgeInsets.all(16.0),
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
                              return ListTile(
                                leading: episode['images'].isNotEmpty
                                    ? Image.network(
                                        episode['images'][0]['url'],
                                        height: 90,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.image_not_supported),
                                title: Text(episode['name']),
                                subtitle: Text(episode['release_date']),
                                onTap: () {
                                  // Handle episode selection, e.g., play episode
                                },
                              );
                            },
                          )
                        : const Text('No episodes available'),
                  ),
                ],
              ),
            ),
    );
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
