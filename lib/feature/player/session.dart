import 'package:audio_session/audio_session.dart';

Future<void> initAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(AudioSessionConfiguration.music());
}