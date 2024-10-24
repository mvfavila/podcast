import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class PodcastPlayer extends StatefulWidget {
  final String episodeUrl;

  const PodcastPlayer({super.key, required this.episodeUrl});

  @override
  PodcastPlayerState createState() => PodcastPlayerState();
}

class PodcastPlayerState extends State<PodcastPlayer> {
  late AudioPlayer _audioPlayer;
  late Duration _duration;
  late Duration _position;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _audioPlayer.setUrl(widget.episodeUrl);
      _audioPlayer.durationStream.listen((d) {
        setState(() {
          _duration = d ?? Duration.zero;
        });
      });
      _audioPlayer.positionStream.listen((p) {
        setState(() {
          _position = p;
        });
      });
    } catch (e) {
      // TODO: handle error
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: _position.inSeconds.toDouble(),
          max: _duration.inSeconds.toDouble(),
          onChanged: (value) {
            setState(() {
              _audioPlayer.seek(Duration(seconds: value.toInt()));
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.replay_10),
              onPressed: () {
                _audioPlayer.seek(
                  _position - const Duration(seconds: 10),
                );
              },
            ),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                if (_isPlaying) {
                  _audioPlayer.pause();
                } else {
                  _audioPlayer.play();
                }
                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.forward_30),
              onPressed: () {
                _audioPlayer.seek(
                  _position + const Duration(seconds: 30),
                );
              },
            ),
          ],
        ),
        Text(
          "${_position.inMinutes}:${_position.inSeconds.remainder(60)} / ${_duration.inMinutes}:${_duration.inSeconds.remainder(60)}",
        ),
      ],
    );
  }
}