import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../../vendor/spotify_service.dart';
import '../../vendor/remote_config_service.dart';

class PodcastSearchScreen extends StatefulWidget {
  const PodcastSearchScreen({super.key});

  @override
  PodcastSearchScreenState createState() => PodcastSearchScreenState();
}

class PodcastSearchScreenState extends State<PodcastSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic>? _podcasts;
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  void _searchPodcasts() async {
    setState(() {
      _isLoading = true;
    });

    final remoteConfig = FirebaseRemoteConfig.instance;
    final remoteConfigService = RemoteConfigService(remoteConfig);
    final spotifyService = SpotifyService(remoteConfigService);
    final podcasts = await spotifyService.searchPodcasts(_controller.text);

    setState(() {
      _podcasts = podcasts;
      _isLoading = false;
    });
  }

  Future<void> _subscribeToPodcast(Map<String, dynamic> podcast) async {
    if (_user == null) return;

    final userSubscriptions = _firestore.collection('users').doc(_user!.uid).collection('subscriptions');

    await userSubscriptions.doc(podcast['id']).set({
      'name': podcast['name'],
      'publisher': podcast['publisher'],
      'image_url': podcast['images'].isNotEmpty ? podcast['images'][0]['url'] : null,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Subscribed to ${podcast['name']}')));
    }
  }

  Future<bool> _isSubscribed(String podcastId) async {
    if (_user == null) return false;

    final subscription = await _firestore.collection('users').doc(_user!.uid).collection('subscriptions').doc(podcastId).get();
    return subscription.exists;
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
                      return FutureBuilder<bool>(
                        future: _isSubscribed(podcast['id']),
                        builder: (context, snapshot) {
                          final isSubscribed = snapshot.data ?? false;
                          return ListTile(
                            title: Text(podcast['name']),
                            subtitle: Text(podcast['publisher']),
                            leading: podcast['images'].isNotEmpty
                                ? Image.network(podcast['images'][0]['url'])
                                : null,
                            trailing: isSubscribed
                                ? const Text('Subscribed', style: TextStyle(color: Colors.green))
                                : ElevatedButton(
                                    onPressed: () => _subscribeToPodcast(podcast),
                                    child: const Text('Subscribe'),
                                  ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
