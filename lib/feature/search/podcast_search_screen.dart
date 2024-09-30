import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:podcast/vendor/spotify_service.dart';
import 'package:podcast/vendor/remote_config_service.dart';

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
  final Map<String, bool> _subscriptions = {};

  @override
  void initState() {
    super.initState();
    _fetchUserSubscriptions();
  }

  Future<void> _fetchUserSubscriptions() async {
    if (_user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(_user.uid)
        .collection('subscriptions')
        .get();

    final subscribedPodcasts = snapshot.docs.map((doc) => doc.id).toList();

    setState(() {
      for (var podcast in subscribedPodcasts) {
        _subscriptions[podcast] = true;
      }
    });
  }

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

  Future<void> _subscribeToPodcast(dynamic podcast) async {
    if (_user == null) return;

    await _firestore
        .collection('users')
        .doc(_user.uid)
        .collection('subscriptions')
        .doc(podcast['id'])
        .set({
      'name': podcast['name'],
      'publisher': podcast['publisher'],
      'image_url': podcast['images'].isNotEmpty ? podcast['images'][0]['url'] : null,
    });

    setState(() {
      _subscriptions[podcast['id']] = true;  // Update the local state
    });
  }

  Future<void> _unsubscribeFromPodcast(dynamic podcast) async {
    if (_user == null) return;

    await _firestore
        .collection('users')
        .doc(_user.uid)
        .collection('subscriptions')
        .doc(podcast['id'])
        .delete();

    setState(() {
      _subscriptions[podcast['id']] = false;  // Update the local state
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
                      final isSubscribed = _subscriptions[podcast['id']] ?? false;

                      return ListTile(
                        title: Text(podcast['name']),
                        subtitle: Text(podcast['publisher']),
                        leading: podcast['images'].isNotEmpty
                            ? Image.network(podcast['images'][0]['url'])
                            : null,
                        trailing: ElevatedButton(
                          onPressed: () {
                            if (isSubscribed) {
                              _unsubscribeFromPodcast(podcast);
                            } else {
                              _subscribeToPodcast(podcast);
                            }
                          },
                          child: Text(isSubscribed ? 'Unsubscribe' : 'Subscribe'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
