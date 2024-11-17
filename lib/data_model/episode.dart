class Episode {
  final String id;
  final String name;
  final String description;
  final DateTime? releaseDate;
  final String imageUrl;
  final int? durationMs;
  int? order;
  bool isPlayed;
  bool isInPlaylist;
  bool isDownloaded;

  Episode({
    required this.id,
    required this.name,
    required this.description,
    required this.releaseDate,
    required this.imageUrl,
    this.order,
    this.durationMs,
    this.isPlayed = false,
    this.isInPlaylist = false,
    this.isDownloaded = false,
  });

  factory Episode.fromJson(String id, Map<String, dynamic> json) {
    return Episode(
      id: id,
      name: json['name'] ?? '',
      description: json['description'],
      releaseDate: json['release_date'] == null ? null : DateTime.parse(json['release_date']),
      imageUrl: getCoverImage(json),
      durationMs: json['duration_ms'],
      isPlayed: json['is_played'] ?? false,
      isInPlaylist: json['is_in_playlist'] ?? false,
      isDownloaded: json['is_downloaded'] ?? false,
      order: json['order'],
    );
  }

  factory Episode.fromFirestore(String id, Map<String, dynamic> data) {
    return Episode.fromJson(id, data);
  }

  static String getCoverImage(Map<String, dynamic> json) {
    if (json['image_url'] != null) {
      return json['image_url'];
    }
    
    if (json['images'] == null) {
      return '';
    }
    
    if (json['images'].isNotEmpty) {
      return json['images'][0]['url'];
    }

    return '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'release_date': _toString(releaseDate),
      'image_url': imageUrl,
      'duration_ms': durationMs,
      'is_played': isPlayed,
      'is_in_playlist': isInPlaylist,
      'is_downloaded': isDownloaded,
      'order': order,
    };
  }

  String _toString(DateTime? date) {
    if (date == null) return '';

    return "${date.year.toString().padLeft(4, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.day.toString().padLeft(2, '0')}";
  }
}