import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RemoteConfigService {
  final String clientIdParameter = 'SPOTIFY_CLIENT_ID';
  final String clientSecretParameter = 'SPOTIFY_CLIENT_SECRET';
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService(this._remoteConfig);

  // Initialize Firebase Remote Config and set default values
  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await _remoteConfig.setDefaults(<String, dynamic>{
      clientIdParameter: dotenv.env['SPOTIFY_CLIENT_ID']!,
      clientSecretParameter: dotenv.env['SPOTIFY_CLIENT_SECRET']!,
    });

    await fetchAndActivate();
  }

  // Fetch and activate the latest remote config
  Future<void> fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // TODO: handle error
    }
  }

  // Get value from Remote Config
  String getSpotifyClientId() {
    return _remoteConfig.getString(clientIdParameter);
  }

  String getSpotifyClientSecret() {
    return _remoteConfig.getString(clientSecretParameter);
  }
}
