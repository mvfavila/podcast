import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:podcast/feature/view/podcast_details_screen.dart';

class ViewSubscriptionsScreen extends StatefulWidget {
  const ViewSubscriptionsScreen({super.key});

  @override
  ViewSubscriptionsScreenState createState() => ViewSubscriptionsScreenState();
}

class ViewSubscriptionsScreenState extends State<ViewSubscriptionsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>>? _subscriptions;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserSubscriptions();
  }

  Future<void> _fetchUserSubscriptions() async {
    if (_user == null) return;

    setState(() {
      _isLoading = true;
    });

    final snapshot = await _firestore
        .collection('users')
        .doc(_user.uid)
        .collection('subscriptions')
        .get();

    setState(() {
      _subscriptions = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'publisher': doc['publisher'],
          'image_url': doc['image_url'],
        };
      }).toList();
      _isLoading = false;
    });
  }

  Future<void> _unsubscribeFromPodcast(String podcastId) async {
    if (_user == null) return;

    await _firestore
        .collection('users')
        .doc(_user.uid)
        .collection('subscriptions')
        .doc(podcastId)
        .delete();

    setState(() {
      _subscriptions = _subscriptions!.where((podcast) => podcast['id'] != podcastId).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Subscriptions')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subscriptions == null || _subscriptions!.isEmpty
              ? const Center(child: Text('No subscriptions found'))
              : ListView.builder(
                  itemCount: _subscriptions!.length,
                  itemBuilder: (context, index) {
                    final podcast = _subscriptions![index];
                    return ListTile(
                      title: Text(podcast['name']),
                      subtitle: Text(podcast['publisher']),
                      leading: podcast['image_url'] != null
                          ? Image.network(podcast['image_url'])
                          : null,
                      trailing: ElevatedButton(
                        onPressed: () {
                          _unsubscribeFromPodcast(podcast['id']);
                        },
                        child: const Text('Unsubscribe'),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PodcastDetailsScreen(podcast: podcast),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
