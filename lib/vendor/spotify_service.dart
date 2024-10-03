import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:podcast/vendor/remote_config_service.dart';

class SpotifyService {
  final RemoteConfigService _remoteConfigService;

  SpotifyService(this._remoteConfigService) {
    _remoteConfigService.initialize();
  }

  Future<String?> getAccessToken() async {
    final clientId = _remoteConfigService.getSpotifyClientId();
    final clientSecret = _remoteConfigService.getSpotifyClientSecret();

    const String authUrl = 'https://accounts.spotify.com/api/token';
    final String credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

    final response = await http.post(
      Uri.parse(authUrl),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      // TODO: log error message
      return null;
    }
  }

  Future<List<dynamic>?> searchPodcasts(String query) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=$query&type=show&limit=10&market=BR'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['shows']['items']; // Returns list of podcast shows
    } else {
      // TODO: log error message
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPodcastDetails(String podcastId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/shows/$podcastId?market=BR'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data; // Returns podcast details including episodes
    } else {
      // TODO: log error message
      return null;
    }
  }
}
