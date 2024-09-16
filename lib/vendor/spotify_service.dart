import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SpotifyService {
  final String clientId = dotenv.env['SPOTIFY_CLIENT_ID']!;
  final String clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET']!;

  Future<String?> getAccessToken() async {
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
      print('Failed to get access token');
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
      print('Failed to fetch podcasts');
      return null;
    }
  }
}
