class Episode {
  final String id;
  final String title;
  final String description;
  final DateTime? publicationDate;
  final String imageUrl;
  final int? durationMs;
  bool isPlayed;
  bool isInPlaylist;

  Episode({
    required this.id,
    required this.title,
    required this.description,
    required this.publicationDate,
    required this.imageUrl,
    this.durationMs,
    this.isPlayed = false,
    this.isInPlaylist = false,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'],
      title: json['name'] ?? '',
      description: json['description'],
      publicationDate: json['release_date'] == null ? null : DateTime.parse(json['release_date']),
      imageUrl: getCoverImage(json),
      durationMs: json['duration_ms'],
    );
  }

  static String getCoverImage(Map<String, dynamic> json) {
    if (json['images'].isNotEmpty) {
      return json['images'][0]['url'];
    }

    return '';
  }
}