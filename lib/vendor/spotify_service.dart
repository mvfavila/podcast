import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:podcast/vendor/remote_config_service.dart';

class SpotifyService {
  static const String market = 'BR';
  final RemoteConfigService _remoteConfigService;

  SpotifyService(this._remoteConfigService) {
    _remoteConfigService.initialize();
  }

  /// Get a Spotify access token using client credentials flow.
  ///
  /// This is a blocking call that waits for the HTTP response. The response is
  /// parsed as JSON and the 'access_token' field is returned as a string. If
  /// the request fails, null is returned.
  ///
  /// The HTTP request is a POST to https://accounts.spotify.com/api/token with
  /// 'Authorization: Basic <base64 encoded credentials>' and
  /// 'Content-Type: application/x-www-form-urlencoded' headers, and
  /// 'grant_type=client_credentials' as the request body.
  ///
  /// The Spotify client ID and secret are obtained from an instance of
  /// RemoteConfigService, which is expected to have been initialized before
  /// calling this method.
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

  /// Searches for podcasts with the given [query].
  ///
  /// Returns a list of podcast shows, or `null` if an error occurred.
  ///
  /// The list of podcast shows will contain the following properties:
  ///   - `id`: The ID of the show.
  ///   - `name`: The name of the show.
  ///   - `publisher`: The publisher of the show.
  ///   - `description`: The description of the show.
  ///   - `images`: A list of images associated with the show.
  ///   - `episodes`: A list of episodes associated with the show.
  ///
  Future<List<dynamic>?> searchPodcasts(String query) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=$query&type=show&limit=10&market=$market'),
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

  /// Returns a map containing details about a podcast with the given [podcastId].
  /// The map will contain the following keys:
  ///   - `id`: The ID of the podcast.
  ///   - `name`: The name of the podcast.
  ///   - `publisher`: The publisher of the podcast.
  ///   - `description`: The description of the podcast.
  ///   - `images`: A list of images associated with the podcast.
  ///   - `episodes`: A list of episodes associated with the podcast.
  ///
  Future<Map<String, dynamic>?> getPodcastDetails(String podcastId) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;

    var uri = Uri.parse('https://api.spotify.com/v1/shows/$podcastId?market=$market');

    final response = await http.get(
      uri,
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

  /// Returns a map containing episodes of a podcast with the given [podcastId].
  ///
  /// The map will contain the following keys:
  ///   - `items`: A list of episodes associated with the podcast.
  ///   - `total`: The total number of episodes.
  ///   - `limit`: The limit of episodes per page.
  ///   - `offset`: The offset of episodes returned.
  ///   - `next`: The URL to fetch the next page of episodes, if available.
  ///   - `previous`: The URL to fetch the previous page of episodes, if available.
  ///
  /// The [limit] parameter is optional and defaults to 5.
  Future<Map<String, dynamic>?> getPodcastEpisodes(String podcastId, {int limit = 5}) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;

    var uri = Uri.parse('https://api.spotify.com/v1/shows/$podcastId/episodes?market=$market&limit=$limit');

    final response = await http.get(
      uri,
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
