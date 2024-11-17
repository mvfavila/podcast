import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:podcast/data_model/episode.dart';
import 'package:podcast/feature/view/building_blocks/episode_tile.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  PlaylistScreenState createState() => PlaylistScreenState();
}

class PlaylistScreenState extends State<PlaylistScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Episode> _playlist = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPlaylist();
  }

  Future<void> _fetchPlaylist() async {
    setState(() {
      _isLoading = true;
    });

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final playlistSnapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('playlist')
        .orderBy('order')
        .get();

    final playedSnapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('episodesCompleted')
        .get();

    final playedEpisodeIds = playedSnapshot.docs.map((doc) => doc.id).toSet();

    List<Episode> playlist = [];
    for (var doc in playlistSnapshot.docs) {
      if (!playedEpisodeIds.contains(doc.id)) {
        playlist.add(Episode.fromFirestore(doc.id, doc.data()));
      }
    }

    setState(() {
      _playlist = playlist;
      _isLoading = false;
    });
  }

  void _reorderPlaylist(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--; // Account for reordering behavior

    setState(() {
      final episode = _playlist.removeAt(oldIndex);
      _playlist.insert(newIndex, episode);
    });

    // Update order in Firestore
    final userId = _auth.currentUser!.uid;
    final batch = _firestore.batch();

    for (int i = 0; i < _playlist.length; i++) {
      final episode = _playlist[i];
      episode.order = i + 1;

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('playlist')
          .doc(episode.id);

      batch.update(docRef, {'order': episode.order});
    }

    await batch.commit();
  }

  Future<void> _removeFromPlaylist(Episode episode) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('playlist')
        .doc(episode.id)
        .delete();

    setState(() {
      _playlist.remove(episode);
    });
  }

  Future<void> _markAsPlayed(Episode episode) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('episodesCompleted')
        .doc(episode.id)
        .set({'played': true});

    _removeFromPlaylist(episode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Playlist')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ReorderableListView(
              onReorder: _reorderPlaylist,
              children: _playlist
                  .map(
                    (episode) => Slidable(
                      key: ValueKey(episode.id),
                      endActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) => _removeFromPlaylist(episode),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Remove',
                          ),
                          SlidableAction(
                            onPressed: (context) => _markAsPlayed(episode),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.check,
                            label: 'Mark Played',
                          ),
                        ],
                      ),
                      child: EpisodeTile(episode: episode, backupImageUrl: '', onToggleInPlaylist: (_){}),
                      
                      // ListTile(
                      //   leading: Image.network(
                      //     episode.imageUrl,
                      //     height: 60,
                      //     width: 60,
                      //     fit: BoxFit.cover,
                      //   ),
                      //   title: Text(
                      //     episode.name,
                      //     maxLines: 2,
                      //     overflow: TextOverflow.ellipsis,
                      //   ),
                      //   subtitle: Text(
                      //     episode.releaseDate.toString(),
                      //     style: TextStyle(fontSize: 12),
                      //   ),
                      //   trailing: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       IconButton(
                      //         icon: Icon(Icons.play_arrow),
                      //         onPressed: () {
                      //           // Handle play episode
                      //         },
                      //       ),
                      //       IconButton(
                      //         icon: Icon(
                      //           episode.isDownloaded
                      //               ? Icons.download_done
                      //               : Icons.download,
                      //         ),
                      //         onPressed: () {
                      //           setState(() {
                      //             episode.isDownloaded = !episode.isDownloaded;
                      //           });
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}