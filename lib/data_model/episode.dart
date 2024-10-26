class Episode {
  final String id;
  final String title;
  final String podcastName;
  final DateTime publicationDate;
  bool isPlayed;
  bool isInPlaylist;

  Episode({
    required this.id,
    required this.title,
    required this.podcastName,
    required this.publicationDate,
    this.isPlayed = false,
    this.isInPlaylist = false,
  });
}